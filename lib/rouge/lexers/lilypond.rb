# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class LilyPond < RegexLexer
      title "LilyPond"
      desc "Markup language for music engraving"
      tag 'lilypond'
      aliases 'ly'
      filenames '*.ly'
      mimetypes 'text/x-lilypond'

      keywords = %w(
        bar clef context glissando key language layout lyricmode lyricsto major
        midi minor new once override paper relative remove score Score set time
        times version with
      )

      state :root do
        rule %r/%.*$/,       Comment::Single
        rule %r/%\{.*?\}%/m, Comment::Multiline

        rule %r/\\(?:#{keywords.join('|')})\b/, Keyword::Reserved
        rule %r/\\\w+\b/, Keyword

        rule %r/[\[\]\{\}\(\)',\/]/, Punctuation # TODO split rule

        rule %r/".*?"/, Str::Double
        rule %r/[a-z]\w*/i, Name
        rule %r/\d+/, Num
        rule %r/\s+/m, Text::Whitespace
      end
    end
  end
end
