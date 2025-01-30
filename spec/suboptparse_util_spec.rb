# frozen_string_literal: true

require "suboptparse/util"

RSpec.describe SubOptParse::Util do
  it "merges hashes" do
    h1 = {a: { b: 0, c: []}}
    h2 = {a: { b: 2, c: [3]}}
    h1 = SubOptParse::Util.recursive_merge(h1, h2)
    expect(h2).to eq(h1)

    # Merge hashes.
    h2[:a][:b] = 3
    expect(3).to_not eq(h1[:a][:b])
    expect(h2).to_not eq(h1)
    h1 = SubOptParse::Util.recursive_merge(h1, h2)
    expect(h2).to eq(h1)

    # Merge arrays.
    h2[:a][:c].push 4
    expect(h2).to_not eq(h1)
    h1 = SubOptParse::Util.recursive_merge(h1, h2)
    expect(h2).to eq(h1)
  end

  it "merges deep hashes" do
    h1 = {a: { b: { c: 1, f: 9}, g: 10 } }
    h2 = {a: { b: { c: 2 , d: { e: 3}}, a: 8} }
    h1 = SubOptParse::Util.recursive_merge(h1, h2)
    expect(h2).to_not eq(h1)
    h2[:a][:b][:f] = 9
    h2[:a][:g] = 10
    expect(h2).to eq(h1)
  end

  it "prefers incoming object if types don't match" do
    h1 = { a: { b: 3}}
    h2 = { a: 1 }
    h1 = SubOptParse::Util.recursive_merge(h1, h2)
    expect(h2).to eq(h1)
  end

  it "appends array values for the incoming object" do
    h1 = { a: [1, 2, 3]}
    h2 = { a: [4, 5, 6]}
    h1 = SubOptParse::Util.recursive_merge(h1, h2)
    expect([1,2,3,4,5,6]).to eq(h1[:a])
  end
end