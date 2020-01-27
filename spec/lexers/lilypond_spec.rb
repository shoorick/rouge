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

    it 'recognizes bar line "|"' do
      assert_tokens_equal '|', ['Punctuation', '|']
    end

    it 'recognizes variable \altoVoice' do
      assert_tokens_equal '\altoVoice', ['Name.Variable', '\altoVoice']
    end

    it 'recognizes command \slurUp' do
      assert_tokens_equal '\slurUp', ['Keyword.Reserved', '\slurUp']
    end

    # Do not work yet
    #it 'recognizes short dynamic signs' do
      #['<', '!', '>'].each { |dynamics|
        #assert_tokens_equal "\\#{dynamics}", ['Keyword.Constant', "\\#{dynamics}"]
      #}
    #end

    it 'recognizes dynamic change' do
      %w(
        cresc crescHairpin crescTextCresc
        decresc dim dimHairpin dimTextDecresc dimTextDim
      ).each { |dynamics|
        assert_tokens_equal "\\#{dynamics}", ['Keyword.Constant', "\\#{dynamics}"]
      }
    end

    it 'recognizes dynamic values' do
      %w(
        ppppp pppp ppp pp p mp
        mf f ff fff ffff fffff
        fp sf sff sp spp sfz rfz
      ).each { |dynamics|
        assert_tokens_equal "\\#{dynamics}", ['Keyword.Constant', "\\#{dynamics}"]
      }
    end

    it 'recognizes Dutch/Finnish/German pitches' do
      %w( a as aeses b h his c es eis g ).each { |pitch|
        assert_tokens_equal pitch, ['Literal.String.Symbol', pitch]
      }
    end

    it 'recognizes Norwegian/Swedish altered pitches' do
      %w( ciss dississ fess gessess ).each { |pitch|
        assert_tokens_equal pitch, ['Literal.String.Symbol', pitch]
      }
    end

    it 'recognizes English altered pitches' do
      %w( af bflat cff dflatflat esharp fx fs asharpsharp bss ).each { |pitch|
        assert_tokens_equal pitch, ['Literal.String.Symbol', pitch]
      }
    end

    it 'recognizes syllable pitches' do
      %w( do re mi fa sol la si ).each { |pitch|
        assert_tokens_equal pitch, ['Literal.String.Symbol', pitch]
      }
    end

    it 'recognizes Catalan/French/Italian/Spanish altered pitches' do
      %w( dod reb miss fax fadd solbb sib ).each { |pitch|
        assert_tokens_equal pitch, ['Literal.String.Symbol', pitch]
      }
    end

    it 'recognizes Flemish double sharpened pitches' do
      %w( dokk mikk ).each { |pitch|
        assert_tokens_equal pitch, ['Literal.String.Symbol', pitch]
      }
    end
  end
end
