var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#DoubleFloats-1",
    "page": "Home",
    "title": "DoubleFloats",
    "category": "section",
    "text": ""
},

{
    "location": "#Introduction-1",
    "page": "Home",
    "title": "Introduction",
    "category": "section",
    "text": "When you are using DoubleFloats, you have three more floating point types:Double64 is a magnitude ordered, nonoverlapping pair of Float64s\nDouble32 is a magnitude ordered, nonoverlapping pair of Float32s\nDouble16 is a magnitude ordered, nonoverlapping pair of Float16sMany arithmetic operations and elementary functions are available with each type.flipsign, copysign, signbit, sign, abs\n==, !=, <, <=, >=, >, isless, isequal\n+, -, *, /, ^, floor, ceil, trunc, round (to integer)\nsquare, cube, sqrt, cbrt\nhypot, normalize\nexp, expm1, log, log1p\nsin, cos, tan, csc, sec, cot\nasin, acos, atan, acsc, asec, acot\nsinh, cosh, tanh, csch, sech, coth\nasinh, acosh, atanh, acsch, asech, acothtodo: round (fractionally)\ntodo: elementary functions for Double32s directlyOverview\nCapabilities\nreference material"
},

{
    "location": "appropriate/#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": ""
},

{
    "location": "appropriate/#The-Types-1",
    "page": "Overview",
    "title": "The Types",
    "category": "section",
    "text": ""
},

{
    "location": "appropriate/#Double64-1",
    "page": "Overview",
    "title": "Double64",
    "category": "section",
    "text": "Double64 is the accuracy stalwart.  Very good values are likely to result.When used with reasonably sized values, the computations should limit the accrual of relative error to 10⋅𝘂², where 𝘂 is the relative rounding unit, the unitinthelastplace of the significand, often eps(x)/2. It is possible to accrue relative error steadily; so some experimentation has guided algorithmic selection. At worst, a sequence of 100000 arithmetic and elementary operations might admit a relative error of 100000 * 10⋅𝘂². The worst is unlikely.One right way to use this type is(a) map your input from Float64s to Double64s (b) compute with Double64s (c) map your resultant values from Double64s to Float64sThe values obtained with cascaded arithimetic and composed elementary functions are reliable and their utility is desireable."
},

{
    "location": "appropriate/#what-it-is-1",
    "page": "Overview",
    "title": "what it is",
    "category": "section",
    "text": "What is that? 𝘂 is the last bit of the significand as a quantity, so a result that has a relative error of 1000000⋅𝘂 is as a report that the final ceil(Int, log2(1_000_000)) bits of the result\'s significand are to be treated as inexactness rather than quantification. That means, for a Float64 value (with a 53-bit significand) 53-20 bits remain reliable, while ~38% of the precision has become unavailable to applications involve other\'s health, wealth, and well-being that are shepherded by responsible persons."
},

{
    "location": "appropriate/#how-it-is-used-1",
    "page": "Overview",
    "title": "how it is used",
    "category": "section",
    "text": "Were one working with Float32s (a 24-bit significand), the entire result would have become unreliable. With Double, the relative error accompanying any basic arithmetic operation is 10⋅𝘂² (10×𝘂^𝟐). It is reasonable to see this squaring as pulling in almost second significand\'s bits.  Our possibly accrued relative error does eat into the number of reliable bits in this second order significance. Nonetheless, if your use requires less than one million successive arithmetic operations, the result obtained is reliable as a Float64 or as a Float32.Capabilities\nreference material"
},

{
    "location": "naming/#",
    "page": "Names",
    "title": "Names",
    "category": "page",
    "text": ""
},

{
    "location": "naming/#names-1",
    "page": "Names",
    "title": "names",
    "category": "section",
    "text": "DoubleFloats is the package.  Double64 and Double32 are the exported types.Double64s store 106 significand bits, 11 exponent bits and two sign bits (one for the higher order Float64 and one for the lower order Float64, and they often differ).  This gives Double64s twice the significand bits of a Float64 with the same exponent range as a Float64.Double32s store 48 significand bits, 8 exponent bits and two sign bits (one for the higher order Float32 and one for the lower order Float32, and they often differ).  This gives Double32s twice the significand bits of a Float32 with the same exponent range as a Float32."
},

{
    "location": "capabilities/#",
    "page": "Capabilities",
    "title": "Capabilities",
    "category": "page",
    "text": ""
},

{
    "location": "capabilities/#Capabilities-1",
    "page": "Capabilities",
    "title": "Capabilities",
    "category": "section",
    "text": ""
},

{
    "location": "capabilities/#predicates-1",
    "page": "Capabilities",
    "title": "predicates",
    "category": "section",
    "text": "Predicates are functions that ask \"yes or no\" questions of their argument[s].       You can ask of a number \"Is this zero?\" or \"Is this one?\" and these predicates     (iszero, isone) will work as expected with almost all numerical types.     The built-in numerical types let you query finiteness (isfinite, isinf).    These are the predicates made available for use with DoubleFloats:      iszero, isnonzero, isone                 #  value == 0, value != 0, value == 1\n  ispositive, isnegative,                  #  value >  0, value <  0\n  isnonnegative, isnonpositive,            #  value >= 0, value <= 0   \n  isinteger, isfractional,                 #  value == round(value)\n  issubnormal,                             #  zero(T) < abs(value) < floatmin(T)\n  isnormal,                                #  !isinf(value) && !isnan(value) && !issubnormal(value)\n  isfinite, isinf,                         #  abs(value) != Inf, abs(value) == Inf\n  isposinf, isneginf,                      #  value == Inf, value == -Inf\n  isnan                                    #  value is not a number (eg 0/0)"
},

{
    "location": "capabilities/#the-basic-arithmetic-operations-1",
    "page": "Capabilities",
    "title": "the basic arithmetic operations",
    "category": "section",
    "text": "addition, subtraction \nmultiplication, square, cube\nreciprocation, division, square root, cube rootThere are arithmetic operations that take two Float64s or Float32s or Float16s and return the corresponding Double64 or Double32 or Double16.  These operations are available in functional form as add2, sub2, mul2, div2 and in infix form using Unicode \\oplus \\ominus \\otimes \\oslash \"⊕ ⊖ ⊗ ⊘\"."
},

{
    "location": "capabilities/#rounding-1",
    "page": "Capabilities",
    "title": "rounding",
    "category": "section",
    "text": "RoundNearest, RoundUp, RoundDown\nRoundToZero, RoundFromZero\nRoundNearestTiesAway, RoundNearestTiesUp"
},

{
    "location": "capabilities/#elementary-mathematical-functions-1",
    "page": "Capabilities",
    "title": "elementary mathematical functions",
    "category": "section",
    "text": "log, exp\nsin, cos, tan, csc, sec, cot\nasin, acos, atan, acsc, asec, acot\nsinh, cosh, tanh, csch, sech, coth\nasinh, acosh, atanh, acsch, asech, acoth"
},

{
    "location": "capabilities/#linear-algebra-1",
    "page": "Capabilities",
    "title": "linear algebra",
    "category": "section",
    "text": "isdiag, ishermitian, isposdef, issymmetric, istril, istriu\nnorm, det, dot, tr, condskeel, logdet, logabsdet\ntranspose, adjoint, tril, triu\ndiag, diagind\nfactorize, lu, lufact, qr, qrfact"
},

{
    "location": "capabilities/#also-1",
    "page": "Capabilities",
    "title": "also",
    "category": "section",
    "text": "random values in [0,1)Overview\nreference material"
},

{
    "location": "references/#",
    "page": "Refs",
    "title": "Refs",
    "category": "page",
    "text": ""
},

{
    "location": "references/#References-1",
    "page": "Refs",
    "title": "References",
    "category": "section",
    "text": "[Double-Double Building Blocks]\nM. Joldes, V. Popescu, and J.M. Muller.\nTight and rigourous error bounds for basic building blocks of double-word arithmetic\n2016, working paper.&nbsp; &nbsp; &rarr;  https://hal.archives-ouvertes.fr/hal-01351529v2/document[Triple-Double Building Blocks]\nChristoph Quirin Lauter.\nBasic building blocks for a triple-double intermediate format\n2005, research report.&nbsp; &nbsp; &rarr;https://hal.inria.fr/inria-00070314/document[Multiple Precision]\nV. Popescu.\nTowards fast and certified multiple-precision librairies.\n2017, thesis.&nbsp; &nbsp; &rarr;  https://hal.archives-ouvertes.fr/tel-01534090/document      [mpfun]\nA Thread-Safe Arbitrary Precision Computation Package\nDavid H. Bailey ∗\nMarch 20, 2017&nbsp; &nbsp; &rarr;  http://www.davidhbailey.com/dhbpapers/mpfun2015.pdf     &nbsp; &nbsp; &rarr;  http://www.davidhbailey.com/dhbsoftware/mpfun-fort-v15.tar.gz     &nbsp; &nbsp; &rarr;  http://www.davidhbailey.com/dhbsoftware/mpfun-mpfr-v07.tar.gz[Faithful Floats]\nM. Lange and S.M. Rump.\nFaithfully Rounded Floating-point Computations\n2017, preprint.&nbsp; &nbsp; &rarr;  http://www.ti3.tu-harburg.de/paper/rump/LaRu2017b.pdf      Nelson H.F. Beebe\nThe Mathematical-Function Computation Handbook\nSpringer, 2017, book&nbsp;J.-M. Muller, N. Brisebarre, F. de Dinechin, C.-P. Jeannerod, V. Lefevre,\n    G. Melquiond, N. Revol, D. Stehle, and S. Torres.\nHandbook of Floating-Point Arithmetic\nBirkhauser Boston, 2010, book&nbsp;"
},

]}
