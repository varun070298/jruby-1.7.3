# -*- encoding: utf-8 -*-
require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "IO.read" do
  before :each do
    @fname = tmp("io_read.txt")
    @contents = "1234567890"
    touch(@fname) { |f| f.write @contents }
  end

  after :each do
    rm_r @fname
  end

  it "reads the contents of a file" do
    IO.read(@fname).should == @contents
  end

  ruby_version_is "1.9" do
    it "calls #to_path on non-String arguments" do
      p = mock('path')
      p.should_receive(:to_path).and_return(@fname)
      IO.read(p)
    end

    it "accepts an empty options Hash" do
      IO.read(@fname, {}).should == @contents
    end

    it "accepts a length, offset, and empty options Hash" do
      IO.read(@fname, 3, 0, {}).should == @contents[0, 3]
    end

    it "raises an IOError if the options Hash specifies write mode" do
      lambda { IO.read(@fname, 3, 0, {:mode => "w"}) }.should raise_error(IOError)
    end

    it "raises an IOError if the options Hash specifies append only mode" do
      lambda { IO.read(@fname, {:mode => "a"}) }.should raise_error(IOError)
    end

    it "reads the file if the options Hash includes read mode" do
      IO.read(@fname, {:mode => "r"}).should == @contents
    end

    it "reads the file if the options Hash includes read/write mode" do
      IO.read(@fname, {:mode => "r+"}).should == @contents
    end

    it "reads the file if the options Hash includes read/write append mode" do
      IO.read(@fname, {:mode => "a+"}).should == @contents
    end
  end

  it "treats second nil argument as no length limit" do
    IO.read(@fname, nil).should == @contents
    IO.read(@fname, nil, 5).should == IO.read(@fname, @contents.length, 5)
  end

  it "treats third nil argument as 0" do
    IO.read(@fname, nil, nil).should == @contents
    IO.read(@fname, 5, nil).should == IO.read(@fname, 5, 0)
  end

  it "reads the contents of a file up to a certain size when specified" do
    IO.read(@fname, 5).should == @contents.slice(0..4)
  end

  it "reads the contents of a file from an offset of a specific size when specified" do
    IO.read(@fname, 5, 3).should == @contents.slice(3, 5)
  end

  it "returns nil at end-of-file when length is passed" do
    IO.read(@fname, 1, 10).should == nil
  end

  it "raises an Errno::ENOENT when the requested file does not exist" do
    rm_r @fname
    lambda { IO.read @fname }.should raise_error(Errno::ENOENT)
  end

  it "raises a TypeError when not passed a String type" do
    lambda { IO.read nil }.should raise_error(TypeError)
  end

  it "raises an ArgumentError when not passed a valid length" do
    lambda { IO.read @fname, -1 }.should raise_error(ArgumentError)
  end

  it "raises an Errno::EINVAL when not passed a valid offset" do
    lambda { IO.read @fname, 0, -1  }.should raise_error(Errno::EINVAL)
    lambda { IO.read @fname, -1, -1 }.should raise_error(Errno::EINVAL)
  end
end

describe "IO.read from a pipe" do
  it "runs the rest as a subprocess and returns the standard output" do
    IO.read("|sh -c 'echo hello'").should == "hello\n"
  end

  it "opens a pipe to a fork if the rest is -" do
    str = IO.read("|-")
    if str # parent
      str.should == "hello from child\n"
    else #child
      puts "hello from child"
      exit!
    end
  end

  it "reads only the specified number of bytes requested" do
    IO.read("|sh -c 'echo hello'", 1).should == "h"
  end

  it "raises Errno::ESPIPE if passed an offset" do
    lambda {
      IO.read("|sh -c 'echo hello'", 1, 1)
    }.should raise_error(Errno::ESPIPE)
  end
end

describe "IO.read on an empty file" do
  before :each do
    @fname = tmp("io_read_empty.txt")
    touch(@fname)
  end

  after :each do
    rm_r @fname
  end

  it "returns nil when length is passed" do
    IO.read(@fname, 1).should == nil
  end

  it "returns an empty string when no length is passed" do
    IO.read(@fname).should == ""
  end
end

describe "IO#read" do

  before :each do
    @fname = tmp("io_read.txt")
    @contents = "1234567890"
    touch(@fname) { |f| f.write @contents }

    @io = open @fname, "r+"
  end

  after :each do
    @io.close
    rm_r @fname
  end

  it "can be read from consecutively" do
    @io.read(1).should == '1'
    @io.read(2).should == '23'
    @io.read(3).should == '456'
    @io.read(4).should == '7890'
  end

  it "clears the output buffer if there is nothing to read" do
    @io.pos = 10

    buf = 'non-empty string'

    @io.read(10, buf).should == nil

    buf.should == ''
  end

  it "consumes zero bytes when reading zero bytes" do
    pre_pos = @io.pos

    @io.read(0).should == ''

    @io.getc.chr.should == '1'
  end

  it "is at end-of-file when everything has been read" do
    @io.read
    @io.eof?.should == true
  end

  it "reads the contents of a file" do
    @io.read.should == @contents
  end

  it "places the specified number of bytes in the buffer" do
    buf = ""
    @io.read 5, buf

    buf.should == "12345"
  end

  it "expands the buffer when too small" do
    buf = "ABCDE"
    @io.read nil, buf

    buf.should == @contents
  end

  it "overwrites the buffer" do
    buf = "ABCDEFGHIJ"
    @io.read nil, buf

    buf.should == @contents
  end

  it "truncates the buffer when too big" do
    buf = "ABCDEFGHIJKLMNO"
    @io.read nil, buf
    buf.should == @contents

    @io.rewind

    buf = "ABCDEFGHIJKLMNO"
    @io.read 5, buf
    buf.should == @contents[0..4]
  end

  ruby_version_is ""..."1.9" do
    it "trucates the buffer to the limit when no data remains" do
      buf = "abc"
      @io.read

      @io.read(2, buf).should be_nil
      buf.should == "ab"
      buf.size.should == 2
    end
  end

  it "returns the given buffer" do
    buf = ""

    @io.read(nil, buf).object_id.should == buf.object_id
  end

  it "coerces the second argument to string and uses it as a buffer" do
    buf = "ABCDE"
    obj = mock("buff")
    obj.should_receive(:to_str).any_number_of_times.and_return(buf)

    @io.read(15, obj).object_id.should_not == obj.object_id
    buf.should == @contents
  end

  it "returns an empty string at end-of-file" do
    @io.read
    @io.read.should == ''
  end

  it "reads the contents of a file when more bytes are specified" do
    @io.read(@contents.length + 1).should == @contents
  end

  it "returns an empty string at end-of-file" do
    @io.read
    @io.read.should == ''
  end

  it "returns an empty string when the current pos is bigger than the content size" do
    @io.pos = 1000
    @io.read.should == ''
  end

  it "returns nil at end-of-file with a length" do
    @io.read
    @io.read(1).should == nil
  end

  it "with length argument returns nil when the current pos is bigger than the content size" do
    @io.pos = 1000
    @io.read(1).should == nil
  end

  it "raises IOError on closed stream" do
    lambda { IOSpecs.closed_io.read }.should raise_error(IOError)
  end
end

platform_is :windows do
  describe "IO#read on Windows" do
    before :each do
      @fname = tmp("io_read.txt")
      touch(@fname, "wb") { |f| f.write "a\r\nb\r\nc" }
    end

    after :each do
      rm_r @fname
      @io.close if @io and !@io.closed?
    end

    it "normalizes line endings in text mode" do
      @io = new_io(@fname, "r")
      @io.read.should == "a\nb\nc"
    end

    it "does not normalize line endings in binary mode" do
      @io = new_io(@fname, "rb")
      @io.read.should == "a\r\nb\r\nc"
    end
  end
end

describe "IO#read with $KCODE set to UTF-8" do
  before :each do
    @kcode, $KCODE = $KCODE, "utf-8"
    @io = IOSpecs.io_fixture "lines.txt"
  end

  after :each do
    $KCODE = @kcode
  end

  it "ignores unicode encoding" do
    @io.readline.should == "Voici la ligne une.\n"
    @io.read(5).should == encode("Qui \303", "binary")
  end
end

ruby_version_is "1.9" do
  describe "IO#read in binary mode" do
    before :each do
      @internal = Encoding.default_internal
      @name = fixture __FILE__, "read_binary.txt"
    end

    after :each do
      Encoding.default_internal = @internal
    end

    it "does not transcode file contents when Encoding.default_internal is set" do
      Encoding.default_internal = "utf-8"

      result = File.open(@name, "rb") { |f| f.read }.chomp

      result.encoding.should == Encoding::ASCII_8BIT
      result.should == "abc\xE2def".force_encoding(Encoding::ASCII_8BIT)
    end

    it "does transcode file contents when an internal encoding is specified" do
      Encoding.default_internal = "euc-jp"

      lambda do
        File.open(@name, "r:binary:utf-8") { |f| f.read }
      end.should raise_error(Encoding::UndefinedConversionError)
    end
  end

  describe "IO.read with BOM" do
    it "reads a file without a bom" do
      name = fixture __FILE__, "no_bom_UTF-8.txt"
      result = File.read(name, :mode => "rb:BOM|utf-8")
      result.force_encoding("ascii-8bit").should == "UTF-8\n"
    end

    it "reads a file with a utf-8 bom" do
      name = fixture __FILE__, "bom_UTF-8.txt"
      result = File.read(name, :mode => "rb:BOM|utf-16le")
      result.force_encoding("ascii-8bit").should == "UTF-8\n"
    end

    it "reads a file with a utf-16le bom" do
      name = fixture __FILE__, "bom_UTF-16LE.txt"
      result = File.read(name, :mode => "rb:BOM|utf-8")
      result.force_encoding("ascii-8bit").should == "U\x00T\x00F\x00-\x001\x006\x00L\x00E\x00\n\x00"
    end

    it "reads a file with a utf-16be bom" do
      name = fixture __FILE__, "bom_UTF-16BE.txt"
      result = File.read(name, :mode => "rb:BOM|utf-8")
      result.force_encoding("ascii-8bit").should == "\x00U\x00T\x00F\x00-\x001\x006\x00B\x00E\x00\n"
    end

    it "reads a file with a utf-32le bom" do
      name = fixture __FILE__, "bom_UTF-32LE.txt"
      result = File.read(name, :mode => "rb:BOM|utf-8")
      result.force_encoding("ascii-8bit").should == "U\x00\x00\x00T\x00\x00\x00F\x00\x00\x00-\x00\x00\x003\x00\x00\x002\x00\x00\x00L\x00\x00\x00E\x00\x00\x00\n\x00\x00\x00"
    end

    it "reads a file with a utf-32be bom" do
      name = fixture __FILE__, "bom_UTF-32BE.txt"
      result = File.read(name, :mode => "rb:BOM|utf-8")
      result.force_encoding("ascii-8bit").should == "\x00\x00\x00U\x00\x00\x00T\x00\x00\x00F\x00\x00\x00-\x00\x00\x003\x00\x00\x002\x00\x00\x00B\x00\x00\x00E\x00\x00\x00\n"
    end
  end
end

with_feature :encoding do
  describe :io_read_internal_encoding, :shared => true do
    it "returns a transcoded String" do
      @io.read.should == "???????????????\n"
    end

    it "sets the String encoding to the internal encoding" do
      @io.read.encoding.should equal(Encoding::UTF_8)
    end

    describe "when passed nil for limit" do
      it "sets the buffer to a transcoded String" do
        result = @io.read(nil, buf = "")
        buf.should equal(result)
        buf.should == "???????????????\n"
      end

      it "sets the buffer's encoding to the internal encoding" do
        buf = "".force_encoding Encoding::ISO_8859_1
        @io.read(nil, buf)
        buf.encoding.should equal(Encoding::UTF_8)
      end
    end
  end

  describe :io_read_size_internal_encoding, :shared => true do
    it "reads bytes when passed a size" do
      @io.read(2).should == "\xa4\xa2".force_encoding(Encoding::ASCII_8BIT)
    end

    it "returns a String in ASCII-8BIT when passed a size" do
      @io.read(4).encoding.should equal(Encoding::ASCII_8BIT)
    end

    it "does not change the buffer's encoding when passed a limit" do
      buf = "".force_encoding Encoding::ISO_8859_1
      @io.read(4, buf)
      buf.should == "\xa4\xa2\xa4\xea".force_encoding(Encoding::ISO_8859_1)
      buf.encoding.should equal(Encoding::ISO_8859_1)
    end

    it "trucates the buffer but does not change the buffer's encoding when no data remains" do
      buf = "abc".force_encoding Encoding::ISO_8859_1
      @io.read

      @io.read(1, buf).should be_nil
      buf.size.should == 0
      buf.encoding.should equal(Encoding::ISO_8859_1)
    end
  end

  describe "IO#read" do
    describe "with internal encoding" do
      after :each do
        @io.close unless @io.closed?
      end

      describe "not specified" do
        before :each do
          @io = IOSpecs.io_fixture "read_euc_jp.txt", "r:euc-jp"
        end

        it "does not transcode the String" do
          @io.read.should == ("???????????????\n").encode(Encoding::EUC_JP)
        end

        it "sets the String encoding to the external encoding" do
          @io.read.encoding.should equal(Encoding::EUC_JP)
        end

        it_behaves_like :io_read_size_internal_encoding, nil
      end

      describe "specified by open mode" do
        before :each do
          @io = IOSpecs.io_fixture "read_euc_jp.txt", "r:euc-jp:utf-8"
        end

        it_behaves_like :io_read_internal_encoding, nil
        it_behaves_like :io_read_size_internal_encoding, nil
      end

      describe "specified by mode: option" do
        before :each do
          @io = IOSpecs.io_fixture "read_euc_jp.txt", :mode => "r:euc-jp:utf-8"
        end

        it_behaves_like :io_read_internal_encoding, nil
        it_behaves_like :io_read_size_internal_encoding, nil
      end

      describe "specified by internal_encoding: option" do
        before :each do
          options = { :mode => "r",
                      :internal_encoding => "utf-8",
                      :external_encoding => "euc-jp" }
          @io = IOSpecs.io_fixture "read_euc_jp.txt", options
        end

        it_behaves_like :io_read_internal_encoding, nil
        it_behaves_like :io_read_size_internal_encoding, nil
      end

      describe "specified by encoding: option" do
        before :each do
          options = { :mode => "r", :encoding => "euc-jp:utf-8" }
          @io = IOSpecs.io_fixture "read_euc_jp.txt", options
        end

        it_behaves_like :io_read_internal_encoding, nil
        it_behaves_like :io_read_size_internal_encoding, nil
      end
    end
  end
end

describe "IO#read with large data" do
  before :each do
    # TODO: what is the significance of this mystery math?
    @data_size = 8096 * 2 + 1024
    @data = "*" * @data_size

    @fname = tmp("io_read.txt")
    touch(@fname) { |f| f.write @data }

    @io = open @fname, "r"
  end

  after :each do
    @io.close
    rm_r @fname
  end

  it "reads all the data at once" do
    File.open(@fname, 'r') { |io| ScratchPad.record io.read }

    ScratchPad.recorded.size.should == @data_size
    ScratchPad.recorded.should == @data
  end

  it "reads only the requested number of bytes" do
    read_size = @data_size / 2
    File.open(@fname, 'r') { |io| ScratchPad.record io.read(read_size) }

    ScratchPad.recorded.size.should == read_size
    ScratchPad.recorded.should == @data[0, read_size]
  end
end
