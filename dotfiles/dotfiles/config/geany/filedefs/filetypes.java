# For complete documentation of this file, please see Geany's main documentation
[styling=C]

[keywords]
primary=abstract ArrayList assert boolean Boolean break byte Byte case catch char Character class const continue default do double Double else enum extends false final finally float Float for future generic goto if implements import inner instanceof int Integer interface LinkedList long Long Math native new null Object outer package private protected public rest return Runnable Scanner short Short static strictfp String super switch synchronized System this Thread throw throws transient try true var void Void volatile while

secondary=finalize getClass notify notifyAll wait main out print println in gc arraycopy close delimiter findInLine findWithinHorizon hasNext hasNextBigDecimal hasNextBigInteger hasNextBoolean hasNextByte hasNextDouble hasNextFloat hasNextInt hasNextLine hasNextLong hasNextShort ioException locale match next nextBigDecimal nextBigInteger nextBoolean nextByte nextDouble nextFloat nextInt nextLine nextLong nextShort radix remove reset skip toString useDelimiter useLocale useRadix charAt codePointAt codePointBefore codePointCount compareTo compareToIgnoreCase concat contains contentEquals copyValueOf endsWith equals equalsIgnoreCase format getBytes getChars hashCode indexOf intern isEmpty lastIndexOf length matches offsetByCodePoints regionMatches replace replaceAll replaceFirst split startsWith subSequence substring toCharArray toLowerCase toUpperCase trim valueOf asList binarySearch copyOf copyOfRange deepEquals deepHashCode deepToString fill sort MAX_PRIORITY MIN_PRIORITY NORM_PRIORITY State activeCount checkAddress clone currentThread	dumpStack enumerate getAllStackTraces getContextClassLoader UncaughtExceptionHandler getDefaultUncaughtExceptionHandler getId getName getPriority getStackTrace getState getThreadGroup getUncaughtExceptionHandler holdsLock interrupt interrupted isAlive isDaemon isInterrupted join run setContextClassLoader setDaemon setDefaultUncaughtExceptionHandler setName setPriority setUncaughtExceptionHandler sleep start MAX_VALUE MIN_VALUE SIZE TYPE bitCount byteValue compare decode doubleValue floatValue getInteger highestOneBit intValue longValue lowestOneBit numberOfLeadingZeros numberOfTrailingZeros parseInt reverse reverseBytes rotateLeft rotateRight shortValue signum toBinaryString toHexString toOctalString sin cos tan asin acos atan atan2 cosh sinh tanh log log1 log101 log1p exp expm1 cbrt sqrt hypot signum signum1 ulp ulp1 abs abs1 abs2 abs3 ceil ceil1 floor floor1 IEEERemainder max min pow random rint round round1 toDegrees toRadians FALSE TRUE booleanValue getBoolean parseBoolean byteValue intValue parseByte Subset UnicodeBlock UnicodeScript COMBINING_SPACING_MARK CONNECTOR_PUNCTUATION CONTROL CURRENCY_SYMBOL DASH_PUNCTUATION DECIMAL_DIGIT_NUMBER DIRECTIONALITY_ARABIC_NUMBER DIRECTIONALITY_BOUNDARY_NEUTRAL DIRECTIONALITY_COMMON_NUMBER_SEPARATOR DIRECTIONALITY_EUROPEAN_NUMBER DIRECTIONALITY_EUROPEAN_NUMBER_SEPARATOR DIRECTIONALITY_EUROPEAN_NUMBER_TERMINATOR DIRECTIONALITY_LEFT_TO_RIGHT DIRECTIONALITY_LEFT_TO_RIGHT_EMBEDDING DIRECTIONALITY_LEFT_TO_RIGHT_OVERRIDE DIRECTIONALITY_NONSPACING_MARK DIRECTIONALITY_OTHER_NEUTRALS DIRECTIONALITY_PARAGRAPH_SEPARATOR DIRECTIONALITY_POP_DIRECTIONAL_FORMAT DIRECTIONALITY_RIGHT_TO_LEFT DIRECTIONALITY_RIGHT_TO_LEFT_ARABIC DIRECTIONALITY_RIGHT_TO_LEFT_EMBEDDING DIRECTIONALITY_RIGHT_TO_LEFT_OVERRIDE DIRECTIONALITY_SEGMENT_SEPARATOR DIRECTIONALITY_UNDEFINED DIRECTIONALITY_WHITESPACE ENCLOSING_MARK END_PUNCTUATION FINAL_QUOTE_PUNCTUATION FORMAT INITIAL_QUOTE_PUNCTUATION LETTER_NUMBER LINE_SEPARATOR LOWERCASE_LETTER MATH_SYMBOLMAX_CODE_POINT MAX_HIGH_SURROGATE MAX_LOW_SURROGATE MAX_RADIXMAX_SURROGATE MIN_CODE_POINT MIN_HIGH_SURROGATE MIN_LOW_SURROGATE MIN_RADIX MIN_SUPPLEMENTARY_CODE_POINT MIN_SURROGATE MODIFIER_LETTER MODIFIER_SYMBOL NON_SPACING_MARK OTHER_LETTER OTHER_NUMBER OTHER_PUNCTUATION OTHER_SYMBOL PARAGRAPH_SEPARATOR PRIVATE_USE SPACE_SEPARATOR START_PUNCTUATION SURROGATE TITLECASE_LETTER UNASSIGNED UPPERCASE_LETTER charCount charValue codePointAt codePointBefore codePointCount digit forDigit getDirectionality getNumericValue getType highSurrogate isAlphabetic isBmpCodePoint isDefined isDigit isHighSurrogate isIdentifierIgnorable isIdeographic isISOControl isJavaIdentifierPart isJavaIdentifierStart isLetter isLetterOrDigit isLowerCase isLowSurrogate isMirrored isSpaceChar isSupplementaryCodePoint isSurrogate isSurrogatePair isTitleCase isUnicodeIdentifierPart isUnicodeIdentifierStart isUpperCase isValidCodePoint isWhitespace lowSurrogate offsetByCodePoints toChars toCodePoint toLowerCase toTitleCase toUpperCase MAX_EXPONENT MIN_EXPONENT NaN MIN_NORMAL NEGATIVE_INFINITY POSITIVE_INFINITY doubleToLongBits doubleToRawLongBits isInfinite isNaN longBitsToDouble parseDouble floatToIntBits floatToRawIntBits intBitsToFloat parseFloat getLong parseLong parseShort modCount add addAll addFirst addLast clear clone contains containsAll descendingIterator element get getFirst getLast iterator isEmpty listIterator offer offerFirst offerLast peek peekFirst peekLast poll pollFirst pollLast pop push remove removeAll removeFirst removeFirstOccurrence removeLast removeLastOccurrence removeRange retainAll set size subList toArray ensureCapacity trimToSize

# documentation keywords for javadoc
doccomment=author deprecated exception param return see serial serialData serialField since throws todo version

[settings]
# default extension used when saving files
extension=java

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file
comment_single=//
# multiline comments
comment_open=/*
comment_close=*/

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
context_action_cmd=

[indentation]
#width=4
# 0 is spaces, 1 is tabs, 2 is tab & spaces
#type=1

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
compiler=javac "%f"
run_cmd=java "%e"
