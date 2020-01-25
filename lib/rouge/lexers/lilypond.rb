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
        accepts alias alternative book bookpart change chordmode
        chords consists context default defaultchild denies description
        drummode drums etc figuremode figures header version-error layout
        lyrics lyricsto markup markuplist midi name notemode override
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

      state :pitch do
        # http://lilypond.org/doc/v2.18/Documentation/notation/writing-pitches
        # North letters
        rule %r/[a-h](?:(?:[ie](?:h|ss?)|f(?:lat)?|s(?:harp)?){,2}|x?)[',]*(?![a-z])/, Str::Symbol
        # South syllables
        rule %r/(?:do|re|mi|fa|sol|la|si)(?:[bdks]{,2}|x?)[',]*(?![a-z])/, Str::Symbol
      end

      state :note do
        mixin :pitch
        # TODO add length
      end

      state :keyword do
        rule %r/\\new\b/, Keyword::Declaration
        rule %r/\\(?:#{keywords_tokens.join('|')})\b/, Keyword::Reserved
        rule %r/\\(?:#{keywords_on_off.join('|')})O(?:n|ff)\b/, Keyword::Reserved
        rule %r/\\(?:#{keywords_up_down_neutral.join('|')})(?:Up|Down|Neutral)\b/, Keyword::Reserved
        rule %r/\\(?:#{keywords_other.join('|')})\b/, Keyword::Reserved
      end

      state :generic do
        rule %r/%.*$/,       Comment::Single
        rule %r/%\{.*?\}%/m, Comment::Multiline

        mixin :keyword

        rule %r/[=\+]/, Operator
        rule %r/[\[\]\{\}\(\)'\.,\/<>\-]/, Punctuation # TODO split rule

        rule %r/#'\w[\w\-]*?"/, Str::Single
        rule %r/#?".*?"/, Str::Double
        rule %r/##[tf]\b/, Keyword::Constant
        rule %r/[a-z]\w*/i, Name
        rule %r/#?[+\-]?\d+(?:\.\d+)?/, Num
        rule %r/\s+/m, Text::Whitespace
      end

      state :lyric do
        mixin :generic
        rule %r/\}/, Keyword::Declaration, :pop!
        rule %r/--/, Punctuation
        rule %r/.+/, Text # non Latin letters too
      end

      state :root do
        rule %r/\\(?:addlyrics|lyricmode)\s*\{/, Keyword::Declaration, :lyric
        rule %r/\\\w+\b/, Keyword

        mixin :note
        mixin :generic
      end
    end
  end
end
