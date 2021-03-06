require 'spec_helper'

describe Overcommit::Hook::PreCommit::JavaCheckstyle do
  let(:config)  { Overcommit::ConfigurationLoader.default_configuration }
  let(:context) { double('context') }
  subject { described_class.new(config, context) }

  before do
    subject.stub(:applicable_files).and_return(%w[file1.java file2.java])
  end

  context 'when checkstyle exits successfully' do
    let(:result) { double('result') }

    before do
      result.stub(:success?).and_return(true)
      subject.stub(:execute).and_return(result)
    end

    context 'with no errors or warnings' do
      before do
        result.stub(:stdout).and_return([
          'Starting audit...',
          'Audit done.',
        ].join("\n"))
      end

      it { should pass }
    end
  end

  context 'when checkstyle exits unsucessfully' do
    let(:result) { double('result') }

    before do
      result.stub(:success?).and_return(false)
      subject.stub(:execute).and_return(result)
    end

    context 'and it reports an error' do
      before do
        result.stub(:stdout).and_return([
          'Starting audit...',
          'file1.java:1: Missing a Javadoc comment.',
          'Audit done.'
        ].join("\n"))

        subject.stub(:modified_lines_in_file).and_return([1, 2])
      end

      it { should fail_hook }
    end
  end
end
