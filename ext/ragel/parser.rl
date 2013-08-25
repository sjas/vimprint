require 'vimprint/model/modes'
require 'vimprint/model/stage'
require 'vimprint/model/commands'

module Vimprint

  %%{
    machine parser;
    action H { @head = p; }
    action T { @tail = p; }

    count = [1-9] >H @T @{ @stage.add_count(strokes) };
    register = '"' [a-z]  >H @T @{ @stage.add_register(strokes) };
    cut   = 'x'   >H @T @{ @stage.add_trigger(strokes) };
    cut_command =
      count?
      register?
      cut @{ @eventlist << NormalCommand.new(@stage.commit) };
    normal  := cut_command*;

  }%%

  class Parser

    attr_accessor :data

    def initialize(listener=[])
      @eventlist = listener
      @stage = Stage.new
      %% write data;
    end

    def process(input)
      @data = input.unpack("c*")
      stack = []
      %% write init;
      %% write exec;
      @eventlist
    end

    def strokes
      @data[@head..@tail].pack('c*')
    end

  end
end