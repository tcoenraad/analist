# frozen_string_literal: true

RSpec.describe Analist::AST::SendNode do
  subject(:send_node) { described_class.new(func) }

  describe '#initialize' do
    context 'with a simple expression' do
      let(:func) { CommonHelpers.parse('1 + 2') }

      it { expect(send_node.method).to eq :+ }
      it { expect(send_node.receiver).to eq AST::Node.new(:int, [1]) }
      it { expect(send_node.args).to eq [AST::Node.new(:int, [2])] }
    end

    context 'with a extended simple expression' do
      let(:func) { CommonHelpers.parse('1 + 2 + 3') }

      it { expect(send_node.method).to eq :+ }
      it do
        expect(send_node.receiver).to eq AST::Node.new(:send,
                                                       [AST::Node.new(:int, [1]), :+,
                                                        AST::Node.new(:int, [2])])
      end
      it { expect(send_node.args).to eq [AST::Node.new(:int, [3])] }
    end

    context 'with a method call' do
      let(:func) { CommonHelpers.parse('User.first') }

      it { expect(send_node.receiver).to eq(AST::Node.new(:const, [nil, :User])) }
      it { expect(send_node.method).to eq :first }
      it { expect(send_node.args).to eq [] }
    end

    context 'with a method call with argument' do
      let(:func) { CommonHelpers.parse('User.where(id: 1)') }

      it { expect(send_node.receiver).to eq(AST::Node.new(:const, [nil, :User])) }
      it { expect(send_node.method).to eq :where }
      it do # rubocop:disable RSpec/ExampleLength
        expect(send_node.args).to eq(
          [AST::Node.new(:hash,
                         [AST::Node.new(
                           :pair, [AST::Node.new(:sym, [:id]), AST::Node.new(:int, [1])]
                         )])]
        )
      end
    end

    context 'with a chained method call' do
      let(:func) { CommonHelpers.parse('User.first.id') }

      it do
        expect(send_node.receiver).to eq(
          AST::Node.new(:send, [AST::Node.new(:const, [nil, :User]), :first])
        )
      end
      it { expect(send_node.method).to eq :id }
      it { expect(send_node.args).to eq [] }
    end

    context 'with multiple arguments' do
      let(:func) { CommonHelpers.parse('method(arg1, arg2)') }

      it do
        expect(send_node.args).to eq [AST::Node.new(:send, [nil, :arg1]),
                                      AST::Node.new(:send, [nil, :arg2])]
      end
    end
  end
end
