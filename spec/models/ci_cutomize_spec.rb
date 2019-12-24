# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
# rubocop:disable RSpec/ExpectActual
RSpec.describe 'CIの強制判定', type: :model do
  it 'ci_successの場合はテストに成功すること', ci_success: true do
    pp "乱数値:#{rand}"
    pp "乱数値:#{rand}"
    pp "Faker1:#{Faker::Name.unique.name}"
    pp "Faker2:#{Faker::Name.unique.name}"

    expect(true).to be_truthy
  end

  it 'ci_successの場合はテストに失敗すること', ci_success: false do
    expect(false).t1o be_truthy unless MyOptions.options.rules[:ci_success] == true
  end
end
# rubocop:enable RSpec/DescribeClass
# rubocop:enable RSpec/ExpectActual
