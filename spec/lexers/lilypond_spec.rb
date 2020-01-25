# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::LilyPond do
  let(:subject) { Rouge::Lexers::LilyPond.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'foo.ly'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-lilypond'
    end

    #it 'guesses by source' do
      #assert_guess :source => '\version "'
    #end
  end

  describe 'lexing' do
    include Support::Lexing

    it 'recognizes one-line "%" comments not followed by a newline' do
      assert_tokens_equal '% comment', ['Comment.Single', '% comment']
    end

end
