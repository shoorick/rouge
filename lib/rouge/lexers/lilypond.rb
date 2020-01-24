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

      # see LilyPond source: lily/parser.yy
      # Keyword tokens with plain escaped name
      keywords_tokens = %w(
        accepts addlyrics alias alternative book bookpart change chordmode
        chords consists context default defaultchild denies description
        drummode drums etc figuremode figures header version-error layout
        lyricmode lyrics lyricsto markup markuplist midi name notemode override
        paper remove repeat rest revert score score-lines sequential set
        simultaneous tempo type unset with
      )

      keywords_on_off = %w(
        cadenza shift sostenuto sustain
      )

      keywords_up_down_neutral = %w(
        arpeggio dots dynamic phrasingSlur slur stem tie tuplet
      )

      keywords_other = %w(
        bar clef glissando key language major minor omit once relative remove
        Score Staff time times version
      )

      state :root do
        rule %r/%.*$/,       Comment::Single
        rule %r/%\{.*?\}%/m, Comment::Multiline

        rule %r/\\(new)\b/, Keyword::Declaration
        rule %r/\\(?:#{keywords_tokens.join('|')})\b/, Keyword::Reserved
        rule %r/\\(?:#{keywords_on_off.join('|')})O(n|ff)\b/, Keyword::Reserved
        rule %r/\\(?:#{keywords_up_down_neutral.join('|')})(Up|Down|Neutral)\b/, Keyword::Reserved
        rule %r/\\(?:#{keywords_other.join('|')})\b/, Keyword::Reserved
        rule %r/\\\w+\b/, Keyword

        rule %r/[\[\]\{\}\(\)',\/<>]/, Punctuation # TODO split rule

        rule %r/".*?"/, Str::Double
        rule %r/[a-z]\w*/i, Name
        rule %r/[+\-]?\d+(\.\d+)?/, Num
        rule %r/\s+/m, Text::Whitespace
      end
    end
  end
end
