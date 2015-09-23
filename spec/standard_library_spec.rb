require "spec_helper"

describe Blueprint::Interpreter do
  describe "even?" do
    it "returns true if a number is even" do
      expect_eval(
        "(even? 4)"
      ).to eq(true)
    end

    it "returns false if a number is odd" do
      expect_eval(
        "(even? 5)"
      ).to eq(false)
    end
  end

  describe "filter" do
    it "can select elements of a list that match a predicate" do
      expect_eval(
        "(filter (lambda (x) (== x 3)) (list 1 3 4 5 2 3 3 5))"
      ).to eq([3, 3, 3])
    end
  end

  describe "if" do
    it "expands into the equivalent cond expression" do
      expect_eval(
        "(if (== 1 2) 3 4)"
      ).to eq(4)
    end

    it "doesn't inadvertently execute the alternative branch" do
      expect_eval(
        "(let ((a 3))" \
        "(if (== 1 2) (set! a 12) a))"
      ).to eq(3)
    end
  end

  describe "let" do
    it "expands into an equivalent lambda expression" do
      expect_eval(
        "(let ((x 3) (y 4)) (+ x y))"
      ).to eq(7)
    end
  end

  describe "load" do
    it "loads and evaluates code from a file" do
      code = "(define (square x) (* x x))"
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with("square.blu").and_return(code)

      expect_eval(
        "(load \"square.blu\")" \
        "(square 3)"
      ).to eq(9)
    end
  end

  describe "map" do
    it "maps a function across a list" do
      expect_eval(
        "(map (lambda (n) (+ 1 n)) (list 1 2 3))"
      ).to eq([2, 3, 4])
    end

    it "returns an empty list when given one" do
      expect_eval(
        "(map (lambda (n) (+ 1 n)) (quote ()))"
      ).to eq([])
    end
  end

  describe "null?" do
    it "returns true when its argument is the empty list" do
      expect_eval("(null? (quote ()))").to eq(true)
    end

    it "returns false otherwise" do
      expect_eval("(null? (quote (1 2)))").to eq(false)
    end
  end

  describe "odd?" do
    it "returns true if a number is odd" do
      expect_eval(
        "(odd? 5)"
      ).to eq(true)
    end

    it "returns false if a number is even" do
      expect_eval(
        "(odd? 4)"
      ).to eq(false)
    end
  end

  describe "reduce" do
    it "can sum up a list of numbers" do
      expect_eval(
        "(reduce (lambda (x y) (+ x y)) 0 (list 1 2 3 4))"
      ).to eq(10)
    end
  end
end
