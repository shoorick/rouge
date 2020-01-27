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
      def self.keywords_tokens
        @keywords_tokens ||= Set.new %w(
          accepts alias alternative book bookpart change chordmode
          chords consists context default defaultchild denies description
          drummode drums etc figuremode figures header version-error layout
          lyrics lyricsto markup markuplist midi name notemode override
          paper remove repeat rest revert score score-lines sequential set
          simultaneous tempo type unset with
        )
      end

      def self.keywords_on_off
        @keywords_on_off ||= Set.new %w(
          cadenza shift sostenuto sustain
        )
      end

      def self.keywords_up_down_neutral
        @keywords_up_down_neutral ||= Set.new %w(
          arpeggio dots dynamic phrasingSlur slur stem tie tuplet
        )
      end

      def self.keywords_other
        @keywords_other ||= Set.new %w(
          bar clef glissando key language major minor omit once relative remove
          Score Staff time times version
        )
      end

      # < ! >
      def self.dynamics
        @dynamics ||= Set.new %w(
          cresc crescHairpin crescTextCresc
          decresc dim dimHairpin dimTextDecresc dimTextDim
          ppppp pppp ppp pp p mp mf f ff fff ffff fffff fp sf sff sp spp sfz rfz
        )
      end

      state :pitch do
        # http://lilypond.org/doc/v2.18/Documentation/notation/writing-pitches
        # North letters
        rule %r/[a-h](?:(?:[ie](?:h|ss?)|f(?:lat)?|s(?:harp)?){,2}|x?)[',]*(?![a-z])/, Str::Symbol
        # South syllables
        rule %r/(?:do|re|mi|fa|sol|la|si)(?:[bdks]{,2}|x?)[',]*(?![a-z])/, Str::Symbol
      end

      state :note do
        mixin :pitch
        # TODO add duration
      end

      state :keyword do
        rule %r/\\new\b/, Keyword::Declaration

        # dynamic signs: \<
        rule %r/\\[<!>]\b/, Keyword::Constant

        # \cadenzaOn
        rule %r/\\(\w+)O(n|ff)\b/ do |m|
          if self.class.keywords_on_off.include?(m[1])
            token Keyword::Reserved
          end
        end

        # \slurUp
        rule %r/\\(\w+)(Up|Down|Neutral)\b/ do |m|
          if self.class.keywords_up_down_neutral.include?(m[1])
            token Keyword::Reserved
          end
        end

        # \version
        rule %r/\\(\w+)\b/ do |m|
          if self.class.dynamics.include?(m[1])
            token Keyword::Constant
          elsif self.class.keywords_tokens.include?(m[1])
            token Keyword::Reserved
          elsif self.class.keywords_other.include?(m[1])
            token Keyword::Reserved
          else
            token Keyword
          end
        end

        #rule %r/\\(?:#{keywords_tokens.join('|')})\b/, Keyword::Reserved
        #rule %r/\\(?:#{keywords_on_off.join('|')})O(?:n|ff)\b/, Keyword::Reserved
        #rule %r/\\(?:#{keywords_up_down_neutral.join('|')})(?:Up|Down|Neutral)\b/, Keyword::Reserved
        #rule %r/\\(?:#{keywords_other.join('|')})\b/, Keyword::Reserved
      end

      state :generic do
        rule %r/%.*$/,       Comment::Single
        rule %r/%\{.*?\}%/m, Comment::Multiline

        mixin :keyword

        rule %r/[=\+]/, Operator
        rule %r/[\[\]\{\}\(\)'\.,\/<>\-~\?!\|]/, Punctuation # TODO split rule

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

        mixin :note
        mixin :generic
      end
    end
  end
end
