# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class LilyPond < RegexLexer
      title "LilyPond"
      desc "LilyPond is software for music engraving and its Markup language"
      tag 'lilypond'
      aliases 'ly'
      filenames '*.ly'
      mimetypes 'text/x-lilypond'

      state :root do
        rule %r/\\(addlyrics|lyricmode)\s*\{/, Keyword::Declaration, :lyric
        rule %r/<(?!<)/, Punctuation, :chord

        mixin :note
        mixin :generic
      end

      # see LilyPond source: lily/parser.yy
      # Keyword tokens with plain escaped name
      def self.keywords_tokens
        @keywords_tokens ||= Set.new %w(
          accepts alias alternative bar barNumberCheck book bookpart break
          breathe change chordmode chords clef consists context default
          defaultchild denies description drummode drums etc fermata figuremode
          figures glissando header key language layout lyrics lyricsto major
          markup markuplist midi minor name notemode omit once override paper
          parenthesize relative remove repeat rest revert score score-lines
          sequential set simultaneous tempo time times type unset version
          version-error with
          Score Staff Voice
          bold italic
          hspace vspace
          column center-column dir-column left-column right-column
          center-align general-align halign left-align right-align
          concat combine
          hcenter-in justify-field justify justify-string
          fill-line fill-with-pattern line
          large larger small smaller
          lower raise
          pad-around pad-markup pad-to-box pad-x
          put-adjacent
          mm cm in pt
        )
      end

      def self.keywords_on_off
        @keywords_on_off ||= Set.new %w(
          bend cadenza ignoreMelisma shift sostenuto sustain
          mergeDifferentlyDotted mergeDifferentlyHeaded
        )
      end

      def self.keywords_up_down_neutral
        @keywords_up_down_neutral ||= Set.new %w(
          arpeggio dots dynamic finger phrasingSlur slur stem tie tuplet
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

      def self.keywords_bare # without backslash
        @keywords_bare ||= Set.new %w(
          ChoirStaff DrumStaff GrandStaff GregorianTranscriptionStaff
          PianoStaff RhythmicStaff StaffGroup TabStaff
          Lyrics MultiMeasureRest Rest Score Staff Voice
          volta
          bass treble treble_8 treble_15
        )
      end

      state :whitespace do
        rule %r/\s+/m, Text::Whitespace
      end

      state :pitch do
        # http://lilypond.org/doc/v2.18/Documentation/notation/writing-pitches
        # Northern letters
        rule %r/[a-h](([ie](h|ss?)|f(lat)?|s(harp)?){,2}|x?)[',]*(?![a-z])/, Str::Symbol
        # Southern syllables
        rule %r/(do|re|mi|fa|sol|la|si)([bdks]{,2}|x?)[',]*(?![a-z])/, Str::Symbol
        # Rests and skips
        rule %r/[Rrs](?![a-z])/, Str::Symbol
      end

      state :duration do
        rule %r/(1|2|4|8|16|32|64|128|256)\.{,3}(\s*\*\s*\d+)?/, Num
      end

      state :note do
        mixin :whitespace
        mixin :pitch
        mixin :duration
      end

      state :chord do
        mixin :whitespace
        mixin :pitch
        mixin :generic
        rule %r/>(?!>)/, Punctuation, :pop!
      end

      state :keyword do
        rule %r/\\new\b/, Keyword::Declaration

        # dynamic signs: \<
        rule %r/\\([<!>])(?!\1)/, Keyword::Constant

        # on/off commands: \cadenzaOn
        rule %r/\\(\w+)O(n|ff)\b/ do |m|
          if self.class.keywords_on_off.include?(m[1])
            token Keyword::Reserved
          end
        end

        # directions: \slurUp
        rule %r/\\(\w+)(Up|Down|Neutral)\b/ do |m|
          if self.class.keywords_up_down_neutral.include?(m[1])
            token Keyword::Reserved
          end
        end

        # backslash prepended words: \version
        rule %r/\\(\w+)\b/ do |m|
          if self.class.dynamics.include?(m[1])
            token Keyword::Constant
          elsif self.class.keywords_tokens.include?(m[1])
            token Keyword::Reserved
          else
            token Name::Variable
          end
        end

        # words without backslash: StaffGroup
        rule %r/\w+\b/ do |m|
          if self.class.keywords_bare.include?(m[0])
            token Str::Symbol
          end
        end
      end

      state :generic do
        mixin :whitespace
        mixin :keyword

        rule %r/%.*$/,       Comment::Single
        rule %r/%\{.*?\}%/m, Comment::Multiline

        rule %r/(#')?[a-z][a-z\-]*(?=\s*=)/i, Name::Variable
        rule %r/[=\+]/, Operator
        rule %r/([\\\/<>]){2}/, Punctuation
        rule %r/[\[\]\{\}\(\)'\.,\/\-~\?!\|^_]/, Punctuation # TODO split rule

        #rule %r/#'\w[\w\-]*?/, Str::Single
        rule %r/#?".*?"/m, Str::Double
        rule %r/##[tf]\b/, Keyword::Constant
        rule %r/#[A-Z]+\b/, Keyword::Constant
        rule %r/[a-z][a-z_\-]*/i, Name
        rule %r/#?[+\-]?\d+(\.\d+)?/, Num
      end

      state :lyric do
        rule %r/\}/, Keyword::Declaration, :pop!
        mixin :generic

        rule %r/--/, Punctuation
        rule %r/__/, Punctuation
        rule %r/.+/, Text # non Latin letters too
      end
    end
  end
end
