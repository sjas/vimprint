gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/vimprint/registry'

module Vimprint

  describe Explanation do

    it "can be a plain string" do
      explain = Explanation.new('undo the last change')
      assert_equal 'undo the last change', explain.render(binding)
    end

    it "can interpolate a local value into a string" do
      count = 5
      explain = Explanation.new(%q{undo the last #{count} changes})
      assert_equal 'undo the last 5 changes', explain.render(binding)
    end

    it "can interpolate many local values into a string" do
      verb = 'move'
      count = 5
      explain = Explanation.new(%q{#{verb} to the start of the #{count.ordinalize} word})
      assert_equal 'move to the start of the 5th word', explain.render(binding)
    end

  end

  describe Registry do

    describe "create_mode()" do

      it "doesn't create duplicates" do
        @normal_mode1 = Registry.create_mode("normal")
        @normal_mode2 = Registry.create_mode("normal")
        assert_same @normal_mode1, @normal_mode2
      end

    end

    describe "get_mode()" do

      before do
        @normal_mode = Registry.create_mode("normal")
        @insert_mode = Registry.create_mode("insert")
      end

      it 'returns the normal_mode registry' do
        mode = Registry.get_mode('normal')
        assert_equal @normal_mode, mode
      end

      it 'returns the insert_mode registry' do
        mode = Registry.get_mode('insert')
        assert_equal @insert_mode, mode
      end

      it 'explodes informatively when asked for a non-existant mode' do
        assert_raises(NoModeError) {Registry.get_mode('sparkles')}
      end

    end

    describe "#get_command" do

      before do
        @normal_mode = Registry.create_mode("normal")
        @normal_mode.create_command('w', 'move to the start of the next word')
      end

      it 'explains the specified command' do
        explained_motion = @normal_mode.get_command('w').template
        assert_equal "move to the start of the next word", explained_motion
      end

      it 'explodes informatively when asked for a non-existent command' do
        assert_raises(NoCommandError) {@normal_mode.get_command('sparkles')}
      end

    end

    describe "#create_command" do

      before do
        @normal_mode = Registry.create_mode("normal")
      end

      it 'instantiates an Explanation and saves it with a signature' do
        template = 'move to the end of the current word'
        @normal_mode.create_command('e', template)
        assert_equal template, @normal_mode.get_command('e').template
      end

      it 'overrides the existing explanation' do
        builtin, overridden = [ 'yank entire line',  'yank to end of line']
        @normal_mode.create_command('Y', builtin)
        @normal_mode.create_command('Y', overridden)
        assert_equal overridden, @normal_mode.get_command('Y').template
      end
    end

    describe '#create_operator' do

      it 'overwrites existing entries' do
        @op1 = Registry.create_operator('d', 'delete')
        @op2 = Registry.create_operator('d', 'cut')
        assert_equal 'cut', Registry.get_operator('d')
      end

    end

    describe '#get_operator' do

      before do
        @cut = Registry.create_operator('d', 'cut')
        @rot13 = Registry.create_operator('g?', 'rot13')
      end

      it 'returns the cut registry' do
        mode = Registry.get_operator('d')
        assert_equal @cut, mode
      end

      it 'returns the rot13 registry' do
        mode = Registry.get_operator('g?')
        assert_equal @rot13, mode
      end

      it 'explodes informatively when asked for a non-existant mode' do
        assert_raises(NoOperatorError) {Registry.get_operator('sparkles')}
      end

    end

  end
end
