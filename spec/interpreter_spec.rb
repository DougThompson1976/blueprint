require "spec_helper"

describe Blueprint::Interpreter do
  it "handles basic arithmetic" do
    expect_eval("(+ 1 2 3)").to eq(6)
    expect_eval("(- 6 2 3)").to eq(1)
    expect_eval("(* 2 2 3)").to eq(12)
    expect_eval("(/ 12 2 3)").to eq(2)
  end

  it "can join strings" do
    expect_eval("(+ \"foo\" \"bar\")").to eq("foobar")
  end

  it "has a modulo operator" do
    expect_eval("(% 12 5)").to eq(2)
    expect_eval("(% 12 6)").to eq(0)
  end

  it "handles quotes" do
    expect_eval("(quote (1 2 3))").to eq([1, 2, 3])
  end

  it "handles syntactic sugar for quotes" do
    expect_eval("'a").to eq(:a)
    expect_eval("'(1 2 3)").to eq([1, 2, 3])
  end

  it "handles conditionals" do
    expect_eval("(cond ((== 1 2) 3) (else 4))").to eq(4)
    expect_eval("(cond ((== 1 1) 3) (else 4))").to eq(3)
  end

  it "handles cons" do
    expect_eval("(cons 1 (quote ()))").to eq([1])
    expect_eval("(cons 1 (quote (2 3)))").to eq([1, 2, 3])
    expect(
      interpreter.eval("(cons (quote (1 2)) (quote (3 4)))")
    ).to eq([[1, 2], 3, 4])
  end

  it "handles first" do
    expect_eval("(first (quote (1 2 3)))").to eq(1)
    expect {
      interpreter.eval("(first (quote ()))")
    }.to raise_error(StandardError)
  end

  it "handles rest" do
    expect_eval("(rest (quote (1)))").to eq([])
    expect_eval("(rest (quote (1 2 3 4)))").to eq([2, 3, 4])
    expect {
      interpreter.eval("(rest (quote ()))")
    }.to raise_error(StandardError)
  end

  it "handles list" do
    expect_eval("(list 1 2 3)").to eq([1, 2, 3])
    expect_eval("(define a 3) (list 1 2 a)").to eq([1, 2, 3])
  end

  it "can set! a variable in a let expression" do
    expect_eval("(let ((a 1)) (set! a 2) a)").to eq(2)
  end

  it "can set! a variable in a nested let expression" do
    expect_eval("(let ((a 1)) (let ((b 2)) (set! a 2)) a)").to eq(2)
  end

  it "can define a variable" do
    expect_eval("(define a 2) a").to eq(2)
  end

  it "can define a function" do
    expect_eval("(define (square x) (* x x)) (square 3)").to eq(9)
  end

  it "handles recursion" do
    expect_eval(
      "(define (fact n) (cond ((== n 0) 1) (else (* n (fact (- n 1))))))" \
      "(fact 6)"
    ).to eq(720)
  end

  it "supports user-defined macros" do
    expect_eval(
      "(defmacro (my-let bindings body)" \
      "  (cons (list (quote lambda)" \
      "              (map (lambda (binding) (first binding))" \
      "                   bindings)" \
      "              body)" \
      "        (map (lambda (x) (first (rest x))) bindings)))" \
      "(my-let ((a 2) (b 3)) (+ a b))"
    ).to eq(5)
  end

  it "supports defining anaphoric macros" do
    expect_eval(
      "(defmacro (aif condition consequent alternative)" \
      "  (list (quote let) (list (list (quote it) condition))" \
      "               (list (quote if) (quote it) consequent alternative)))" \
      "(define (square x) (* x x))" \
      "(aif (+ 1 2 3 4)" \
      "     (square it)" \
      "     0)" \
    ).to eq(100)
  end

  it "can slurp the contents of a file into a string" do
    contents = "here's some content!"
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("my-file.txt").and_return(contents)

    expect_eval(
      "(slurp-file \"my-file.txt\")"
    ).to eq(contents)
  end

  it "can read ASTs from strings" do
    expect_eval(
      "(read \"(+ 1 2 3)\")"
    ).to eq([[:+, 1, 2, 3]])
  end

  it "can apply a function to a list" do
    expect_eval(
      "(apply '+ '(1 2))"
    ).to eq(3)
  end

  it "can eval lists" do
    expect_eval(
      "(eval '(+ 1 2))"
    ).to eq(3)
  end

  describe "syntactic sugar for macros" do
    it "expands quasiquoted literals" do
      expect_eval("`4").to eq(4)
    end

    it "evaluates and inserts unquoted expressions" do
      expect_eval("`(,(+ 1 2) 3)").to eq([3, 3])
    end

    it "handles an unquote right after a quasiquote" do
      expect_eval("`,(+ 1 2)").to eq(3)
    end
  end
end
