# frozen_string_literal: true

require_relative '../libraries/osx_helper'

RSpec.describe Users::OsxHelper do
  subject(:helper) do
    Class.new do
      include Users::OsxHelper

      attr_accessor :status

      def shell_out(_cmd)
        status
      end
    end.new
  end

  let(:status) { instance_double('Status', stdout: "group1 100\n", stderr: "warning\n", exitstatus: 0) }

  before do
    helper.status = status
  end

  it 'returns mutable dscl output buffers when frozen string literals are enabled' do
    expect(helper.dscl('list /Groups gid')).to eq(['dscl . -list /Groups gid', status, "group1 100\n", "warning\n"])
  end
end
