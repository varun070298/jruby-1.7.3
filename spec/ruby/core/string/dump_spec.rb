# -*- encoding: utf-8 -*-
require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "String#dump" do
  it "taints the result if self is tainted" do
    "foo".taint.dump.tainted?.should == true
    "foo\n".taint.dump.tainted?.should == true
  end

  ruby_version_is "1.9" do
    it "untrusts the result if self is untrusted" do
      "foo".untrust.dump.untrusted?.should == true
      "foo\n".untrust.dump.untrusted?.should == true
    end
  end

  it "returns a subclass instance" do
    StringSpecs::MyString.new.dump.should be_an_instance_of(StringSpecs::MyString)
  end

  it "returns a string with special characters replaced with \\<char> notation" do
    [ ["\a", '"\\a"'],
      ["\b", '"\\b"'],
      ["\t", '"\\t"'],
      ["\n", '"\\n"'],
      ["\v", '"\\v"'],
      ["\f", '"\\f"'],
      ["\r", '"\\r"'],
      ["\e", '"\\e"']
    ].should be_computed_by(:dump)
  end

  it "returns a string with \" and \\ escaped with a backslash" do
    [ ["\"", '"\\""'],
      ["\\", '"\\\\"']
    ].should be_computed_by(:dump)
  end

  it "returns a string with \\#<char> when # is followed by $, @, {" do
    [ ["\#$", '"\\#$"'],
      ["\#@", '"\\#@"'],
      ["\#{", '"\\#{"']
    ].should be_computed_by(:dump)
  end

  it "returns a string with # not escaped when followed by any other character" do
    [ ["#", '"#"'],
      ["#1", '"#1"']
    ].should be_computed_by(:dump)
  end

  it "returns a string with printable non-alphanumeric characters unescaped" do
    [ [" ", '" "'],
      ["!", '"!"'],
      ["$", '"$"'],
      ["%", '"%"'],
      ["&", '"&"'],
      ["'", '"\'"'],
      ["(", '"("'],
      [")", '")"'],
      ["*", '"*"'],
      ["+", '"+"'],
      [",", '","'],
      ["-", '"-"'],
      [".", '"."'],
      ["/", '"/"'],
      [":", '":"'],
      [";", '";"'],
      ["<", '"<"'],
      ["=", '"="'],
      [">", '">"'],
      ["?", '"?"'],
      ["@", '"@"'],
      ["[", '"["'],
      ["]", '"]"'],
      ["^", '"^"'],
      ["_", '"_"'],
      ["`", '"`"'],
      ["{", '"{"'],
      ["|", '"|"'],
      ["}", '"}"'],
      ["~", '"~"']
    ].should be_computed_by(:dump)
  end

  it "returns a string with numeric characters unescaped" do
    [ ["0", '"0"'],
      ["1", '"1"'],
      ["2", '"2"'],
      ["3", '"3"'],
      ["4", '"4"'],
      ["5", '"5"'],
      ["6", '"6"'],
      ["7", '"7"'],
      ["8", '"8"'],
      ["9", '"9"'],
    ].should be_computed_by(:dump)
  end

  it "returns a string with upper-case alpha characters unescaped" do
    [ ["A", '"A"'],
      ["B", '"B"'],
      ["C", '"C"'],
      ["D", '"D"'],
      ["E", '"E"'],
      ["F", '"F"'],
      ["G", '"G"'],
      ["H", '"H"'],
      ["I", '"I"'],
      ["J", '"J"'],
      ["K", '"K"'],
      ["L", '"L"'],
      ["M", '"M"'],
      ["N", '"N"'],
      ["O", '"O"'],
      ["P", '"P"'],
      ["Q", '"Q"'],
      ["R", '"R"'],
      ["S", '"S"'],
      ["T", '"T"'],
      ["U", '"U"'],
      ["V", '"V"'],
      ["W", '"W"'],
      ["X", '"X"'],
      ["Y", '"Y"'],
      ["Z", '"Z"']
    ].should be_computed_by(:dump)
  end

  it "returns a string with lower-case alpha characters unescaped" do
    [ ["a", '"a"'],
      ["b", '"b"'],
      ["c", '"c"'],
      ["d", '"d"'],
      ["e", '"e"'],
      ["f", '"f"'],
      ["g", '"g"'],
      ["h", '"h"'],
      ["i", '"i"'],
      ["j", '"j"'],
      ["k", '"k"'],
      ["l", '"l"'],
      ["m", '"m"'],
      ["n", '"n"'],
      ["o", '"o"'],
      ["p", '"p"'],
      ["q", '"q"'],
      ["r", '"r"'],
      ["s", '"s"'],
      ["t", '"t"'],
      ["u", '"u"'],
      ["v", '"v"'],
      ["w", '"w"'],
      ["x", '"x"'],
      ["y", '"y"'],
      ["z", '"z"']
    ].should be_computed_by(:dump)
  end

  ruby_version_is ""..."1.9" do
    it "returns a string with non-printing characters replaced with \\0nn notation" do
      [ ["\000", '"\\000"'],
        ["\001", '"\\001"'],
        ["\002", '"\\002"'],
        ["\003", '"\\003"'],
        ["\004", '"\\004"'],
        ["\005", '"\\005"'],
        ["\006", '"\\006"'],
        ["\016", '"\\016"'],
        ["\017", '"\\017"'],
        ["\020", '"\\020"'],
        ["\021", '"\\021"'],
        ["\022", '"\\022"'],
        ["\023", '"\\023"'],
        ["\024", '"\\024"'],
        ["\025", '"\\025"'],
        ["\026", '"\\026"'],
        ["\027", '"\\027"'],
        ["\030", '"\\030"'],
        ["\031", '"\\031"'],
        ["\032", '"\\032"'],
        ["\034", '"\\034"'],
        ["\035", '"\\035"'],
        ["\036", '"\\036"'],
        ["\177", '"\\177"'],
        ["\200", '"\\200"'],
        ["\201", '"\\201"'],
        ["\202", '"\\202"'],
        ["\203", '"\\203"'],
        ["\204", '"\\204"'],
        ["\205", '"\\205"'],
        ["\206", '"\\206"'],
        ["\207", '"\\207"'],
        ["\210", '"\\210"'],
        ["\211", '"\\211"'],
        ["\212", '"\\212"'],
        ["\213", '"\\213"'],
        ["\214", '"\\214"'],
        ["\215", '"\\215"'],
        ["\216", '"\\216"'],
        ["\217", '"\\217"'],
        ["\220", '"\\220"'],
        ["\221", '"\\221"'],
        ["\222", '"\\222"'],
        ["\223", '"\\223"'],
        ["\224", '"\\224"'],
        ["\225", '"\\225"'],
        ["\226", '"\\226"'],
        ["\227", '"\\227"'],
        ["\230", '"\\230"'],
        ["\231", '"\\231"'],
        ["\232", '"\\232"'],
        ["\233", '"\\233"'],
        ["\234", '"\\234"'],
        ["\235", '"\\235"'],
        ["\236", '"\\236"'],
        ["\237", '"\\237"'],
        ["\240", '"\\240"'],
        ["\241", '"\\241"'],
        ["\242", '"\\242"'],
        ["\243", '"\\243"'],
        ["\244", '"\\244"'],
        ["\245", '"\\245"'],
        ["\246", '"\\246"'],
        ["\247", '"\\247"'],
        ["\250", '"\\250"'],
        ["\251", '"\\251"'],
        ["\252", '"\\252"'],
        ["\253", '"\\253"'],
        ["\254", '"\\254"'],
        ["\255", '"\\255"'],
        ["\256", '"\\256"'],
        ["\257", '"\\257"'],
        ["\260", '"\\260"'],
        ["\261", '"\\261"'],
        ["\262", '"\\262"'],
        ["\263", '"\\263"'],
        ["\264", '"\\264"'],
        ["\265", '"\\265"'],
        ["\266", '"\\266"'],
        ["\267", '"\\267"'],
        ["\270", '"\\270"'],
        ["\271", '"\\271"'],
        ["\272", '"\\272"'],
        ["\273", '"\\273"'],
        ["\274", '"\\274"'],
        ["\275", '"\\275"'],
        ["\276", '"\\276"'],
        ["\277", '"\\277"'],
        ["\300", '"\\300"'],
        ["\301", '"\\301"'],
        ["\302", '"\\302"'],
        ["\303", '"\\303"'],
        ["\304", '"\\304"'],
        ["\305", '"\\305"'],
        ["\306", '"\\306"'],
        ["\307", '"\\307"'],
        ["\310", '"\\310"'],
        ["\311", '"\\311"'],
        ["\312", '"\\312"'],
        ["\313", '"\\313"'],
        ["\314", '"\\314"'],
        ["\315", '"\\315"'],
        ["\316", '"\\316"'],
        ["\317", '"\\317"'],
        ["\320", '"\\320"'],
        ["\321", '"\\321"'],
        ["\322", '"\\322"'],
        ["\323", '"\\323"'],
        ["\324", '"\\324"'],
        ["\325", '"\\325"'],
        ["\326", '"\\326"'],
        ["\327", '"\\327"'],
        ["\330", '"\\330"'],
        ["\331", '"\\331"'],
        ["\332", '"\\332"'],
        ["\333", '"\\333"'],
        ["\334", '"\\334"'],
        ["\335", '"\\335"'],
        ["\336", '"\\336"'],
        ["\337", '"\\337"'],
        ["\340", '"\\340"'],
        ["\341", '"\\341"'],
        ["\342", '"\\342"'],
        ["\343", '"\\343"'],
        ["\344", '"\\344"'],
        ["\345", '"\\345"'],
        ["\346", '"\\346"'],
        ["\347", '"\\347"'],
        ["\350", '"\\350"'],
        ["\351", '"\\351"'],
        ["\352", '"\\352"'],
        ["\353", '"\\353"'],
        ["\354", '"\\354"'],
        ["\355", '"\\355"'],
        ["\356", '"\\356"'],
        ["\357", '"\\357"'],
        ["\360", '"\\360"'],
        ["\361", '"\\361"'],
        ["\362", '"\\362"'],
        ["\363", '"\\363"'],
        ["\364", '"\\364"'],
        ["\365", '"\\365"'],
        ["\366", '"\\366"'],
        ["\367", '"\\367"'],
        ["\370", '"\\370"'],
        ["\371", '"\\371"'],
        ["\372", '"\\372"'],
        ["\373", '"\\373"'],
        ["\374", '"\\374"'],
        ["\375", '"\\375"'],
        ["\376", '"\\376"'],
        ["\377", '"\\377"']
      ].should be_computed_by(:dump)
    end

    describe "with $KCODE == 'NONE'" do
      before :each do
        @kcode = $KCODE
      end

      after :each do
        $KCODE = @kcode
      end

      it "returns a string with bytes represented in stringified octal notation" do
        $KCODE = "NONE"
        "??????".dump.should == "\"\\303\\244\\303\\266\\303\\274\""
      end
    end

    describe "with $KCODE == 'UTF-8'" do
      before :each do
        @kcode = $KCODE
      end

      after :each do
        $KCODE = @kcode
      end

      it "returns a string with bytes represented in stringified octal notation" do
        $KCODE = "UTF-8"
        "??????".dump.should == "\"\\303\\244\\303\\266\\303\\274\""
      end
    end
  end

  ruby_version_is "1.9" do
    it "returns a string with non-printing ASCII characters replaced by \\x notation" do
      # Avoid the file encoding by computing the string with #chr.
      [ [0000.chr, '"\\x00"'],
        [0001.chr, '"\\x01"'],
        [0002.chr, '"\\x02"'],
        [0003.chr, '"\\x03"'],
        [0004.chr, '"\\x04"'],
        [0005.chr, '"\\x05"'],
        [0006.chr, '"\\x06"'],
        [0016.chr, '"\\x0E"'],
        [0017.chr, '"\\x0F"'],
        [0020.chr, '"\\x10"'],
        [0021.chr, '"\\x11"'],
        [0022.chr, '"\\x12"'],
        [0023.chr, '"\\x13"'],
        [0024.chr, '"\\x14"'],
        [0025.chr, '"\\x15"'],
        [0026.chr, '"\\x16"'],
        [0027.chr, '"\\x17"'],
        [0030.chr, '"\\x18"'],
        [0031.chr, '"\\x19"'],
        [0032.chr, '"\\x1A"'],
        [0034.chr, '"\\x1C"'],
        [0035.chr, '"\\x1D"'],
        [0036.chr, '"\\x1E"'],
        [0037.chr, '"\\x1F"'],
        [0177.chr, '"\\x7F"'],
        [0200.chr, '"\\x80"'],
        [0201.chr, '"\\x81"'],
        [0202.chr, '"\\x82"'],
        [0203.chr, '"\\x83"'],
        [0204.chr, '"\\x84"'],
        [0205.chr, '"\\x85"'],
        [0206.chr, '"\\x86"'],
        [0207.chr, '"\\x87"'],
        [0210.chr, '"\\x88"'],
        [0211.chr, '"\\x89"'],
        [0212.chr, '"\\x8A"'],
        [0213.chr, '"\\x8B"'],
        [0214.chr, '"\\x8C"'],
        [0215.chr, '"\\x8D"'],
        [0216.chr, '"\\x8E"'],
        [0217.chr, '"\\x8F"'],
        [0220.chr, '"\\x90"'],
        [0221.chr, '"\\x91"'],
        [0222.chr, '"\\x92"'],
        [0223.chr, '"\\x93"'],
        [0224.chr, '"\\x94"'],
        [0225.chr, '"\\x95"'],
        [0226.chr, '"\\x96"'],
        [0227.chr, '"\\x97"'],
        [0230.chr, '"\\x98"'],
        [0231.chr, '"\\x99"'],
        [0232.chr, '"\\x9A"'],
        [0233.chr, '"\\x9B"'],
        [0234.chr, '"\\x9C"'],
        [0235.chr, '"\\x9D"'],
        [0236.chr, '"\\x9E"'],
        [0237.chr, '"\\x9F"'],
        [0240.chr, '"\\xA0"'],
        [0241.chr, '"\\xA1"'],
        [0242.chr, '"\\xA2"'],
        [0243.chr, '"\\xA3"'],
        [0244.chr, '"\\xA4"'],
        [0245.chr, '"\\xA5"'],
        [0246.chr, '"\\xA6"'],
        [0247.chr, '"\\xA7"'],
        [0250.chr, '"\\xA8"'],
        [0251.chr, '"\\xA9"'],
        [0252.chr, '"\\xAA"'],
        [0253.chr, '"\\xAB"'],
        [0254.chr, '"\\xAC"'],
        [0255.chr, '"\\xAD"'],
        [0256.chr, '"\\xAE"'],
        [0257.chr, '"\\xAF"'],
        [0260.chr, '"\\xB0"'],
        [0261.chr, '"\\xB1"'],
        [0262.chr, '"\\xB2"'],
        [0263.chr, '"\\xB3"'],
        [0264.chr, '"\\xB4"'],
        [0265.chr, '"\\xB5"'],
        [0266.chr, '"\\xB6"'],
        [0267.chr, '"\\xB7"'],
        [0270.chr, '"\\xB8"'],
        [0271.chr, '"\\xB9"'],
        [0272.chr, '"\\xBA"'],
        [0273.chr, '"\\xBB"'],
        [0274.chr, '"\\xBC"'],
        [0275.chr, '"\\xBD"'],
        [0276.chr, '"\\xBE"'],
        [0277.chr, '"\\xBF"'],
        [0300.chr, '"\\xC0"'],
        [0301.chr, '"\\xC1"'],
        [0302.chr, '"\\xC2"'],
        [0303.chr, '"\\xC3"'],
        [0304.chr, '"\\xC4"'],
        [0305.chr, '"\\xC5"'],
        [0306.chr, '"\\xC6"'],
        [0307.chr, '"\\xC7"'],
        [0310.chr, '"\\xC8"'],
        [0311.chr, '"\\xC9"'],
        [0312.chr, '"\\xCA"'],
        [0313.chr, '"\\xCB"'],
        [0314.chr, '"\\xCC"'],
        [0315.chr, '"\\xCD"'],
        [0316.chr, '"\\xCE"'],
        [0317.chr, '"\\xCF"'],
        [0320.chr, '"\\xD0"'],
        [0321.chr, '"\\xD1"'],
        [0322.chr, '"\\xD2"'],
        [0323.chr, '"\\xD3"'],
        [0324.chr, '"\\xD4"'],
        [0325.chr, '"\\xD5"'],
        [0326.chr, '"\\xD6"'],
        [0327.chr, '"\\xD7"'],
        [0330.chr, '"\\xD8"'],
        [0331.chr, '"\\xD9"'],
        [0332.chr, '"\\xDA"'],
        [0333.chr, '"\\xDB"'],
        [0334.chr, '"\\xDC"'],
        [0335.chr, '"\\xDD"'],
        [0336.chr, '"\\xDE"'],
        [0337.chr, '"\\xDF"'],
        [0340.chr, '"\\xE0"'],
        [0341.chr, '"\\xE1"'],
        [0342.chr, '"\\xE2"'],
        [0343.chr, '"\\xE3"'],
        [0344.chr, '"\\xE4"'],
        [0345.chr, '"\\xE5"'],
        [0346.chr, '"\\xE6"'],
        [0347.chr, '"\\xE7"'],
        [0350.chr, '"\\xE8"'],
        [0351.chr, '"\\xE9"'],
        [0352.chr, '"\\xEA"'],
        [0353.chr, '"\\xEB"'],
        [0354.chr, '"\\xEC"'],
        [0355.chr, '"\\xED"'],
        [0356.chr, '"\\xEE"'],
        [0357.chr, '"\\xEF"'],
        [0360.chr, '"\\xF0"'],
        [0361.chr, '"\\xF1"'],
        [0362.chr, '"\\xF2"'],
        [0363.chr, '"\\xF3"'],
        [0364.chr, '"\\xF4"'],
        [0365.chr, '"\\xF5"'],
        [0366.chr, '"\\xF6"'],
        [0367.chr, '"\\xF7"'],
        [0370.chr, '"\\xF8"'],
        [0371.chr, '"\\xF9"'],
        [0372.chr, '"\\xFA"'],
        [0373.chr, '"\\xFB"'],
        [0374.chr, '"\\xFC"'],
        [0375.chr, '"\\xFD"'],
        [0376.chr, '"\\xFE"'],
        [0377.chr, '"\\xFF"']
      ].should be_computed_by(:dump)
    end

    it "returns a string with non-printing single-byte UTF-8 characters replaced by \\x notation" do
      [ [0000.chr('utf-8'), '"\x00"'],
        [0001.chr('utf-8'), '"\x01"'],
        [0002.chr('utf-8'), '"\x02"'],
        [0003.chr('utf-8'), '"\x03"'],
        [0004.chr('utf-8'), '"\x04"'],
        [0005.chr('utf-8'), '"\x05"'],
        [0006.chr('utf-8'), '"\x06"'],
        [0016.chr('utf-8'), '"\x0E"'],
        [0017.chr('utf-8'), '"\x0F"'],
        [0020.chr('utf-8'), '"\x10"'],
        [0021.chr('utf-8'), '"\x11"'],
        [0022.chr('utf-8'), '"\x12"'],
        [0023.chr('utf-8'), '"\x13"'],
        [0024.chr('utf-8'), '"\x14"'],
        [0025.chr('utf-8'), '"\x15"'],
        [0026.chr('utf-8'), '"\x16"'],
        [0027.chr('utf-8'), '"\x17"'],
        [0030.chr('utf-8'), '"\x18"'],
        [0031.chr('utf-8'), '"\x19"'],
        [0032.chr('utf-8'), '"\x1A"'],
        [0034.chr('utf-8'), '"\x1C"'],
        [0035.chr('utf-8'), '"\x1D"'],
        [0036.chr('utf-8'), '"\x1E"'],
        [0037.chr('utf-8'), '"\x1F"'],
        [0177.chr('utf-8'), '"\x7F"']
      ].should be_computed_by(:dump)
    end

    it "returns a string with multi-byte UTF-8 characters replaced by \\u{} notation with lower-case hex digits" do
      [ [0200.chr('utf-8'), '"\u{80}"'],
        [0201.chr('utf-8'), '"\u{81}"'],
        [0202.chr('utf-8'), '"\u{82}"'],
        [0203.chr('utf-8'), '"\u{83}"'],
        [0204.chr('utf-8'), '"\u{84}"'],
        [0206.chr('utf-8'), '"\u{86}"'],
        [0207.chr('utf-8'), '"\u{87}"'],
        [0210.chr('utf-8'), '"\u{88}"'],
        [0211.chr('utf-8'), '"\u{89}"'],
        [0212.chr('utf-8'), '"\u{8a}"'],
        [0213.chr('utf-8'), '"\u{8b}"'],
        [0214.chr('utf-8'), '"\u{8c}"'],
        [0215.chr('utf-8'), '"\u{8d}"'],
        [0216.chr('utf-8'), '"\u{8e}"'],
        [0217.chr('utf-8'), '"\u{8f}"'],
        [0220.chr('utf-8'), '"\u{90}"'],
        [0221.chr('utf-8'), '"\u{91}"'],
        [0222.chr('utf-8'), '"\u{92}"'],
        [0223.chr('utf-8'), '"\u{93}"'],
        [0224.chr('utf-8'), '"\u{94}"'],
        [0225.chr('utf-8'), '"\u{95}"'],
        [0226.chr('utf-8'), '"\u{96}"'],
        [0227.chr('utf-8'), '"\u{97}"'],
        [0230.chr('utf-8'), '"\u{98}"'],
        [0231.chr('utf-8'), '"\u{99}"'],
        [0232.chr('utf-8'), '"\u{9a}"'],
        [0233.chr('utf-8'), '"\u{9b}"'],
        [0234.chr('utf-8'), '"\u{9c}"'],
        [0235.chr('utf-8'), '"\u{9d}"'],
        [0236.chr('utf-8'), '"\u{9e}"'],
        [0237.chr('utf-8'), '"\u{9f}"'],
      ].should be_computed_by(:dump)
    end

    it "includes .force_encoding(name) if the encoding isn't ASCII compatible" do
      "\u{876}".encode('utf-16be').dump.should == "\"\\bv\".force_encoding(\"UTF-16BE\")"
      "\u{876}".encode('utf-16le').dump.should == "\"v\\b\".force_encoding(\"UTF-16LE\")"
    end
  end
end
