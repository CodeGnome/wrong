require "./test/test_helper"

require "minitest/spec"
require "minitest/unit"

require "wrong/assert"
require "wrong/adapters/minitest"

describe "basic assert features" do

  before do
    @test_case_instance = Class.new(Wrong::MiniTestAdapter.minitest_base_class).new("x")
  end

  it "raises minitest assertion failures" do
    test_case_instance = Class.new(Wrong::MiniTestAdapter.minitest_base_class).new("x")
    assert {
      rescuing {
        test_case_instance.assert { 1==2 }
      }.is_a?(MiniTest::Assertion)
    }
  end

  it "passes asserts with no block up to the framework's assert method" do
    e = rescuing { assert(1 == 2) }
    assert { e.message == "Failed assertion, no message given." }

    e = rescuing { assert(1 == 2, "black is white") }
    assert { e.message == "black is white" }
  end

  it "passes denys with no block up to the framework's assert method" do
    e = rescuing { deny(2 + 2 == 4) }
    assert { e.message == "Failed assertion, no message given." }

    e = rescuing { deny(2 + 2 == 4, "up is down") }
    assert { e.message == "up is down" }
  end

  # TODO: optionally print a warning when calling the framework assert

  it "makes Wrong's assert and deny available to minitest tests" do
    class MyFailingAssertTest < Wrong::MiniTestAdapter.minitest_base_class
      def initialize
        super("assert test")
      end

      def test_fail
        assert { 1==2 }
      end
    end

    class MyFailingDenyTest < Wrong::MiniTestAdapter.minitest_base_class
      def initialize
        super("deny test")
      end

      def test_fail
        deny { 1==1 }
      end
    end

    msg = rescuing { MyFailingAssertTest.new.test_fail }.message
    assert { msg.include?("Expected (1 == 2)") }

    msg = rescuing { MyFailingDenyTest.new.test_fail }.message
    assert { msg.include?("Didn't expect (1 == 1)") }
  end
end

describe 'reports number of assertions' do
  before do
    @test = Class.new(Wrong::MiniTestAdapter.minitest_base_class).new("x")
  end

  it 'assert{} should bump number of assertions' do
    @test.assert {true}
    assert {@test.minitest_assertion_count == 1}
  end

  it 'assert() should not bump twice number of assertions' do
    @test.assert(true)
    assert {@test.minitest_assertion_count == 1}
  end

  it 'deny{} should bump number of assertions' do
    @test.deny {false}
    assert {@test.minitest_assertion_count == 1}
  end

  it 'deny() should bump once number of assertions' do
    @test.deny(false)
    assert {@test.minitest_assertion_count == 1}
  end
end

