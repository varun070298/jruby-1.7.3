# encoding: UTF-8
require File.expand_path('../spec_helper', __FILE__)

load_extension('string')

describe :rb_str_new2, :shared => true do
  it "returns a new string object calling strlen on the passed C string" do
    # Hardcoded to pass const char * = "hello\0invisible"
    @s.send(@method, "hello\0not used").should == "hello"
  end

  ruby_version_is ""..."1.9" do
    it "raises an ArgumentError if passed NULL" do
      lambda { @s.send(@method, nil) }.should raise_error(ArgumentError)
    end
  end

  ruby_version_is "1.9" do
    it "encodes the string with ASCII_8BIT" do
      @s.send(@method, "hello").encoding.should == Encoding::ASCII_8BIT
    end
  end

end

describe "C-API String function" do
  before :each do
    @s = CApiStringSpecs.new
  end

  class ValidTostrTest
    def to_str
      "ruby"
    end
  end

  class InvalidTostrTest
    def to_str
      []
    end
  end

  ruby_version_is "1.8.7" do
    describe "rb_str_set_len" do
      before :each do
        # Make a completely new copy of the string
        # for every example (#dup doesn't cut it).
        @str = "abcdefghij"[0..-1]
      end

      it "reduces the size of the string" do
        @s.rb_str_set_len(@str, 5).should == "abcde"
      end

      it "inserts a NULL byte at the length" do
        @s.rb_str_set_len(@str, 5).should == "abcde"
        @s.rb_str_set_len(@str, 8).should == "abcde\x00gh"
      end

      it "updates the string's attributes visible in C code" do
        @s.rb_str_set_len_RSTRING_LEN(@str, 4).should == 4
      end
    end
  end

  describe "rb_str_buf_new" do
    it "returns the equivalent of an empty string" do
      @s.rb_str_buf_new(10, nil).should == ""
    end

    it "returns a string that can be appended to" do
      str = @s.rb_str_buf_new(10, "defg")
      str << "abcde"
      str.should == "abcde"
    end

    it "returns a string that can be concatentated to another string" do
      str = @s.rb_str_buf_new(10, "defg")
      ("abcde" + str).should == "abcde"
    end

    it "returns a string whose bytes can be accessed by RSTRING_PTR" do
      str = @s.rb_str_buf_new(10, "abcdefghi")
      @s.rb_str_new(str, 10).should == "abcdefghi\x00"
    end

    ruby_version_is ""..."1.9" do
      it "returns a string that can be modified by rb_str_resize" do
        str = @s.rb_str_buf_new(10, "abcde")
        @s.rb_str_resize(str, 4).should == "abcd"
        @s.RSTRING_LEN(str).should == 4
      end

      it "returns a string which can be assigned to from C" do
        str = "hello"
        buf = @s.rb_str_buf_new(str.size, nil)
        @s.RSTRING_ptr_write(buf, str)
        buf.should == str
      end
    end

    ruby_version_is "1.8.7" do
      it "returns a string that can be modified by rb_str_set_len" do
        str = @s.rb_str_buf_new(10, "abcdef")
        @s.rb_str_set_len(str, 4)
        str.should == "abcd"

        @s.rb_str_set_len(str, 8)
        str[0, 6].should == "abcd\x00f"
        @s.RSTRING_LEN(str).should == 8
      end
    end
  end

  describe "rb_str_buf_new2" do
    it "returns a new string object calling strlen on the passed C string" do
      # Hardcoded to pass const char * = "hello\0invisible"
      @s.rb_str_buf_new2.should == "hello"
    end
  end

  describe "rb_str_new" do
    it "returns a new string object from a char buffer of len characters" do
      @s.rb_str_new("hello", 3).should == "hel"
    end

    it "returns an empty string if len is 0" do
      @s.rb_str_new("hello", 0).should == ""
    end
  end

  describe "rb_str_new2" do
    it_behaves_like :rb_str_new2, :rb_str_new2
  end

  ruby_version_is "1.9" do
    describe "rb_str_new_cstr" do
      it_behaves_like :rb_str_new2, :rb_str_new_cstr
    end

    describe "rb_usascii_str_new" do
      it "creates a new String with US-ASCII Encoding from a char buffer of len characters" do
        str = encode("abc", "us-ascii")
        result = @s.rb_usascii_str_new("abcdef", 3)
        result.should == str
        result.encoding.should == Encoding::US_ASCII
      end
    end

    describe "rb_usascii_str_new_cstr" do
      it "creates a new String with US-ASCII Encoding" do
        str = encode("abc", "us-ascii")
        result = @s.rb_usascii_str_new_cstr("abc")
        result.should == str
        result.encoding.should == Encoding::US_ASCII
      end
    end

    describe "rb_str_encode" do
      it "returns a String in the destination encoding" do
        result = @s.rb_str_encode("abc", Encoding::ISO_8859_1, 0, nil)
        result.encoding.should == Encoding::ISO_8859_1
      end

      it "transcodes the String" do
        result = @s.rb_str_encode("???????????????", "euc-jp", 0, nil)
        result.should == "\xa4\xa2\xa4\xea\xa4\xac\xa4\xc8\xa4\xa6".force_encoding("euc-jp")
        result.encoding.should == Encoding::EUC_JP
      end

      it "returns a dup of the original String" do
        a = "abc"
        b = @s.rb_str_encode("abc", "us-ascii", 0, nil)
        a.should_not equal(b)
      end

      it "accepts encoding flags" do
        result = @s.rb_str_encode("a\xffc", "us-ascii",
                                  Encoding::Converter::INVALID_REPLACE, nil)
        result.should == "a?c"
        result.encoding.should == Encoding::US_ASCII
      end

      it "accepts an encoding options Hash specifying replacement String" do
        # Yeah, MRI aborts with rb_bug() if the options Hash is not frozen
        options = { :replace => "b" }.freeze
        result = @s.rb_str_encode("a\xffc", "us-ascii",
                                  Encoding::Converter::INVALID_REPLACE,
                                  options)
        result.should == "abc"
        result.encoding.should == Encoding::US_ASCII
      end
    end
  end

  describe "rb_str_new3" do
    it "returns a copy of the string" do
      str1 = "hi"
      str2 = @s.rb_str_new3 str1
      str1.should == str2
      str1.object_id.should_not == str2.object_id
    end
  end

  describe "rb_str_new4" do
    it "returns the original string if it is already frozen" do
      str1 = "hi"
      str1.freeze
      str2 = @s.rb_str_new4 str1
      str1.should == str2
      str1.should equal(str2)
      str1.frozen?.should == true
      str2.frozen?.should == true
    end

    it "returns a frozen copy of the string" do
      str1 = "hi"
      str2 = @s.rb_str_new4 str1
      str1.should == str2
      str1.should_not equal(str2)
      str2.frozen?.should == true
    end
  end

  describe "rb_str_dup" do
    it "returns a copy of the string" do
      str1 = "hi"
      str2 = @s.rb_str_dup str1
      str1.should == str2
      str1.object_id.should_not == str2.object_id
    end
  end

  describe "rb_str_append" do
    it "appends a string to another string" do
      @s.rb_str_append("Hello", " Goodbye").should == "Hello Goodbye"
    end
  end

  describe "rb_str_plus" do
    it "returns a new string from concatenating two other strings" do
      @s.rb_str_plus("Hello", " Goodbye").should == "Hello Goodbye"
    end
  end

  describe "rb_str_buf_cat" do
    it "concatenates a C string to a ruby string" do
      @s.rb_str_buf_cat("Your house is on fire").should == "Your house is on fire?"
    end
  end

  describe "rb_str_cat" do
    it "concatenates a C string to ruby string" do
      @s.rb_str_cat("Your house is on fire").should == "Your house is on fire?"
    end
  end

  describe "rb_str_cat2" do
    it "concatenates a C string to a ruby string" do
      @s.rb_str_cat2("Your house is on fire").should == "Your house is on fire?"
    end
  end

  describe "rb_str_cmp" do
    it "returns 0 if two strings are identical" do
      @s.rb_str_cmp("ppp", "ppp").should == 0
    end

    it "returns -1 if the first string is shorter than the second" do
      @s.rb_str_cmp("xxx", "xxxx").should == -1
    end

    it "returns -1 if the first string is lexically less than the second" do
      @s.rb_str_cmp("xxx", "yyy").should == -1
    end

    it "returns 1 if the first string is longer than the second" do
      @s.rb_str_cmp("xxxx", "xxx").should == 1
    end

    it "returns 1 if the first string is lexically greater than the second" do
      @s.rb_str_cmp("yyy", "xxx").should == 1
    end
  end

  describe "rb_str_split" do
    it "splits strings over a splitter" do
      @s.rb_str_split("Hello,Goodbye").should == ["Hello", "Goodbye"]
    end
  end

  describe "rb_str2inum" do
    it "converts a string to a number given a base" do
      @s.rb_str2inum("10", 10).should == 10
      @s.rb_str2inum("A", 16).should == 10
    end
  end

  describe "rb_cstr2inum" do
    it "converts a C string to a Fixnum given a base" do
      @s.rb_cstr2inum("10", 10).should == 10
      @s.rb_cstr2inum("10", 16).should == 16
    end

    it "converts a C string to a Bignum given a base" do
      @s.rb_cstr2inum(bignum_value.to_s, 10).should == bignum_value
    end

    it "converts a C string to a Fixnum non-strictly if base is not 0" do
      @s.rb_cstr2inum("1234a", 10).should == 1234
    end

    it "converts a C string to a Fixnum strictly if base is 0" do
      lambda { @s.rb_cstr2inum("1234a", 0) }.should raise_error(ArgumentError)
    end
  end

  describe "rb_cstr_to_inum" do
    it "converts a C string to a Fixnum given a base" do
      @s.rb_cstr_to_inum("1234", 10, true).should == 1234
    end

    it "converts a C string to a Bignum given a base" do
      @s.rb_cstr_to_inum(bignum_value.to_s, 10, true).should == bignum_value
    end

    it "converts a C string to a Fixnum non-strictly" do
      @s.rb_cstr_to_inum("1234a", 10, false).should == 1234
    end

    it "converts a C string to a Fixnum strictly" do
      lambda { @s.rb_cstr_to_inum("1234a", 10, true) }.should raise_error(ArgumentError)
    end
  end

  ruby_version_is "1.9" do
    describe "rb_str_subseq" do
      it "returns a byte-indexed substring" do
        str = encode("\x00\x01\x02\x03\x04", "binary")
        @s.rb_str_subseq(str, 1, 2).should == encode("\x01\x02", "binary")
      end
    end
  end

  describe "rb_str_substr" do
    it "returns a substring" do
      "hello".length.times do |time|
        @s.rb_str_substr("hello", 0, time + 1).should == "hello"[0..time]
      end
    end
  end

  describe "rb_str_to_str" do
    it "calls #to_str to coerce the value to a String" do
      @s.rb_str_to_str("foo").should == "foo"
      @s.rb_str_to_str(ValidTostrTest.new).should == "ruby"
    end

    it "raises a TypeError if coercion fails" do
      lambda { @s.rb_str_to_str(0) }.should raise_error(TypeError)
      lambda { @s.rb_str_to_str(InvalidTostrTest.new) }.should raise_error(TypeError)
    end
  end

  ruby_version_is ""..."1.9" do
    describe "RSTRING" do
      it "returns struct with a pointer to the string's contents" do
        str = "xyz"
        chars = []
        @s.RSTRING_ptr_iterate(str) do |c|
          chars << c
        end
        chars.should == [120, 121, 122]
      end

      it "allows changing the characters in the string" do
        str = "abc"
        @s.RSTRING_ptr_assign(str, 70)
        str.should == "FFF"
      end

      it "allows changing the string and calling a rb_str_xxx function" do
        str = "abc"
        @s.RSTRING_ptr_assign_call(str)
        str.should == "axd"
      end

      it "allows changing the string and calling a method via rb_funcall" do
        str = "abc"
        @s.RSTRING_ptr_assign_funcall(str)
        str.should == "axce"
      end

      it "returns a struct with the string's length" do
        @s.RSTRING_len("dewdrops").should == 8
      end
    end
  end

  describe "RSTRING_PTR" do
    it "returns a pointer to the string's contents" do
      str = "abc"
      chars = []
      @s.RSTRING_PTR_iterate(str) do |c|
        chars << c
      end
      chars.should == [97, 98, 99]
    end

    it "allows changing the characters in the string" do
      str = "abc"
      @s.RSTRING_PTR_assign(str, 65)
      str.should == "AAA"
    end

    it "reflects changes after a rb_funcall" do
      lamb = proc { |s| s.replace "NEW CONTENT" }

      str = "beforebefore"

      ret = @s.RSTRING_PTR_after_funcall(str, lamb)

      str.should == "NEW CONTENT"
      ret.should == str
    end
  end

  describe "RSTRING_LEN" do
    it "returns the size of the string" do
      @s.RSTRING_LEN("gumdrops").should == 8
    end
  end

  ruby_version_is "1.9" do
    describe "RSTRING_LENINT" do
      it "returns the size of a string" do
        @s.RSTRING_LENINT("silly").should == 5
      end
    end
  end

  describe "StringValue" do
    it "does not call #to_str on a String" do
      str = "genuine"
      str.should_not_receive(:to_str)
      @s.StringValue(str)
    end

    it "does not call #to_s on a String" do
      str = "genuine"
      str.should_not_receive(:to_str)
      @s.StringValue(str)
    end

    it "calls #to_str on non-String objects" do
      str = mock("fake")
      str.should_receive(:to_str).and_return("wannabe")
      @s.StringValue(str)
    end

    it "does not call #to_s on non-String objects" do
      str = mock("fake")
      str.should_not_receive(:to_s)
      lambda { @s.StringValue(str) }.should raise_error(TypeError)
    end
  end

  describe "rb_str_resize" do
    it "reduces the size of the string" do
      str = @s.rb_str_resize("test", 2)
      str.size.should == 2
      @s.RSTRING_LEN(str).should == 2
      str.should == "te"
    end

    it "updates the string's attributes visible in C code" do
      @s.rb_str_resize_RSTRING_LEN("test", 2).should == 2
    end

    it "increases the size of the string" do
      str = @s.rb_str_resize("test", 12)
      str.size.should == 12
      @s.RSTRING_LEN(str).should == 12
      str[0, 4].should == "test"
    end
  end

  describe "rb_str_inspect" do
    it "returns the equivalent of calling #inspect on the String" do
      @s.rb_str_inspect("value").should == %["value"]
    end
  end

  describe "rb_str_intern" do
    it "returns a symbol created from the string" do
      @s.rb_str_intern("symbol").should == :symbol
    end

    ruby_version_is ""..."1.9" do
      it "raises an ArgumentError if passed an empty string" do
        lambda { @s.rb_str_intern("") }.should raise_error(ArgumentError)
      end

      it "raises an ArgumentError if the passed string contains NULL characters" do
        lambda { @s.rb_str_intern("no\0no") }.should raise_error(ArgumentError)
      end
    end

    ruby_version_is "1.9" do
      it "returns a symbol even if passed an empty string" do
        @s.rb_str_intern("").should == "".to_sym
      end

      it "returns a symbol even if the passed string contains NULL characters" do
        @s.rb_str_intern("no\0no").should == "no\0no".to_sym
      end
    end
  end

  ruby_version_is ""..."1.9" do
    describe "rb_str2cstr" do
      it "returns a pointer to the string's content and its length" do
        str, len = @s.rb_str2cstr('any str', true)
        str.should == 'any str'
        len.should == 7
      end

      it "allows changing the characters in the string" do
        str = 'any str'
        # Hardcoded to set "foo\0"
        @s.rb_str2cstr_replace(str)
        str.should == "foo\0str"
      end
    end

    describe "STR2CSTR" do
      it "returns a pointer to the string's content" do
        @s.STR2CSTR('any str').should == 'any str'
      end

      it "allows changing the characters in the string" do
        str = 'any str'
        # Hardcoded to set "foo\0"
        @s.STR2CSTR_replace(str)
        str.should == "foo\0str"
      end
    end
  end

  describe "rb_str_freeze" do
    it "freezes the string" do
      s = ""
      @s.rb_str_freeze(s).should == s
      s.frozen?.should be_true
    end
  end

  describe "rb_str_hash" do
    it "hashes the string into a number" do
      s = "hello"
      @s.rb_str_hash(s).should == s.hash
    end
  end

  extended_on :rubinius do
    describe "rb_str_ptr" do
      it "returns struct with a pointer to the string's contents" do
        str = "xyz"
        chars = []
        @s.rb_str_ptr_iterate(str) do |c|
          chars << c
        end
        chars.should == [120, 121, 122]
      end

      it "allows changing the characters in the string" do
        str = "abc"
        @s.rb_str_ptr_assign(str, 70)
        str.should == "FFF"
      end

      it "allows changing the string and calling a rb_str_xxx function" do
        str = "abc"
        @s.rb_str_ptr_assign_call(str)
        str.should == "axcd"
      end

      it "allows changing the string and calling a method via rb_funcall" do
        str = "abc"
        @s.rb_str_ptr_assign_funcall(str)
        str.should == "axce"
      end
    end

    describe "rb_str_ptr_readonly" do
      it "returns struct with a pointer to the string's contents" do
        str = "xyz"
        chars = []
        @s.rb_str_ptr_readonly_iterate(str) do |c|
          chars << c
        end
        chars.should == [120, 121, 122]
      end
    end

    describe "rb_str_len" do
      it "returns the string's length" do
        @s.rb_str_len("dewdrops").should == 8
      end
    end
  end
end

ruby_version_is "1.9" do

  describe "rb_str_length" do
    it "returns the string's length" do
      @s.rb_str_length("dewdrops").should == 8
    end

    it "counts characters in multi byte encodings" do
      @s.rb_str_length("d??wdrops").should == 8
    end
  end

  describe "rb_str_equal" do
    it "compares two same strings" do
      s = "hello"
      @s.rb_str_equal(s, "hello").should be_true
    end

    it "compares two different strings" do
      s = "hello"
      @s.rb_str_equal(s, "hella").should be_false
    end
  end

  describe :rb_external_str_new, :shared => true do
    it "returns a String in the default external encoding" do
      Encoding.default_external = "UTF-8"
      @s.send(@method, "abc").encoding.should == Encoding::UTF_8
    end

    it "returns an ASCII-8BIT encoded string if any non-ascii bytes are present and default external is US-ASCII" do
      Encoding.default_external = "US-ASCII"
      @s.send(@method, "\x80abc").encoding.should == Encoding::ASCII_8BIT
    end

    it "returns a tainted String" do
      @s.send(@method, "abc").tainted?.should be_true
    end
  end

  describe "C-API String function" do
    before :each do
      @s = CApiStringSpecs.new
      @encoding = Encoding.default_external
    end

    after :each do
      Encoding.default_external = @encoding
    end

    describe "rb_external_str_new" do
      it_behaves_like :rb_external_str_new, :rb_external_str_new
    end

    describe "rb_external_str_new_cstr" do
      it_behaves_like :rb_external_str_new, :rb_external_str_new_cstr
    end

    describe "rb_external_str_new_with_enc" do
      it "returns a String in the specified encoding" do
        s = @s.rb_external_str_new_with_enc("abc", 3, Encoding::UTF_8)
        s.encoding.should == Encoding::UTF_8
      end

      it "returns an ASCII-8BIT encoded String if any non-ascii bytes are present and the specified encoding is US-ASCII" do
        s = @s.rb_external_str_new_with_enc("\x80abc", 4, Encoding::US_ASCII)
        s.encoding.should == Encoding::ASCII_8BIT
      end

      it "returns a tainted String" do
        s = @s.rb_external_str_new_with_enc("abc", 3, Encoding::US_ASCII)
        s.tainted?.should be_true
      end
    end
  end
end
