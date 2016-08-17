//
//  AGXPDF417DecodedBitStreamParser.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/3.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  TheLevelUp/ZXingObjC
//

//
//  Copyright 2014 ZXing authors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "AGXPDF417DecodedBitStreamParser.h"
#import "AGXGcodeError.h"
#import "AGXCharacterSetECI.h"

typedef enum {
    AGXPDF417ModeAlpha = 0,
    AGXPDF417ModeLower,
    AGXPDF417ModeMixed,
    AGXPDF417ModePunct,
    AGXPDF417ModeAlphaShift,
    AGXPDF417ModePunctShift
} AGXPDF417Mode;

const int AGX_PDF417_TEXT_COMPACTION_MODE_LATCH = 900;
const int AGX_PDF417_BYTE_COMPACTION_MODE_LATCH = 901;
const int AGX_PDF417_NUMERIC_COMPACTION_MODE_LATCH = 902;
const int AGX_PDF417_BYTE_COMPACTION_MODE_LATCH_6 = 924;
const int AGX_PDF417_ECI_USER_DEFINED = 925;
const int AGX_PDF417_ECI_GENERAL_PURPOSE = 926;
const int AGX_PDF417_ECI_CHARSET = 927;
const int AGX_PDF417_BEGIN_MACRO_PDF417_CONTROL_BLOCK = 928;
const int AGX_PDF417_BEGIN_MACRO_PDF417_OPTIONAL_FIELD = 923;
const int AGX_PDF417_MACRO_PDF417_TERMINATOR = 922;
const int AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE = 913;
const int AGX_PDF417_MAX_NUMERIC_CODEWORDS = 15;

const int AGX_PDF417_PL = 25;
const int AGX_PDF417_LL = 27;
const int AGX_PDF417_AS = 27;
const int AGX_PDF417_ML = 28;
const int AGX_PDF417_AL = 28;
const int AGX_PDF417_PS = 29;
const int AGX_PDF417_PAL = 29;

const unichar AGX_PDF417_PUNCT_CHARS[] = {
    ';', '<', '>', '@', '[', '\\', ']', '_', '`', '~', '!',
    '\r', '\t', ',', ':', '\n', '-', '.', '$', '/', '"', '|', '*',
    '(', ')', '?', '{', '}', '\''};

const unichar AGX_PDF417_MIXED_CHARS[] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '&',
    '\r', '\t', ',', ':', '#', '-', '.', '$', '/', '+', '%', '*',
    '=', '^'};

const int AGX_PDF417_NUMBER_OF_SEQUENCE_CODEWORDS = 2;

const NSStringEncoding AGX_PDF417_DECODING_DEFAULT_ENCODING = NSISOLatin1StringEncoding;

/**
 * Table containing values for the exponent of 900.
 * This is used in the numeric compaction decode algorithm.
 */
static NSArray *AGX_PDF417_EXP900 = nil;

@implementation AGXPDF417DecodedBitStreamParser

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        NSMutableArray *exponents = [NSMutableArray arrayWithCapacity:16];
        [exponents addObject:[NSDecimalNumber one]];
        NSDecimalNumber *nineHundred = [NSDecimalNumber decimalNumberWithString:@"900"];
        [exponents addObject:nineHundred];
        for (int i = 2; i < 16; i++) {
            [exponents addObject:[exponents[i - 1] decimalNumberByMultiplyingBy:nineHundred]];
        }
        AGX_PDF417_EXP900 = [[NSArray alloc] initWithArray:exponents];
    });
}

+ (AGXDecoderResult *)decode:(AGXIntArray *)codewords ecLevel:(NSString *)ecLevel error:(NSError **)error {
    NSMutableString *result = [NSMutableString stringWithCapacity:codewords.length * 2];
    NSStringEncoding encoding = AGX_PDF417_DECODING_DEFAULT_ENCODING;
    // Get compaction mode
    int codeIndex = 1;
    int code = codewords.array[codeIndex++];
//    AGXPDF417ResultMetadata *resultMetadata = [[AGXPDF417ResultMetadata alloc] init];
    while (codeIndex < codewords.array[0]) {
        switch (code) {
            case AGX_PDF417_TEXT_COMPACTION_MODE_LATCH:
                codeIndex = [self textCompaction:codewords codeIndex:codeIndex result:result];
                break;
            case AGX_PDF417_BYTE_COMPACTION_MODE_LATCH:
            case AGX_PDF417_BYTE_COMPACTION_MODE_LATCH_6:
                codeIndex = [self byteCompaction:code codewords:codewords encoding:encoding codeIndex:codeIndex result:result];
                break;
            case AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE:
                [result appendFormat:@"%C", (unichar)codewords.array[codeIndex++]];
                break;
            case AGX_PDF417_NUMERIC_COMPACTION_MODE_LATCH:
                codeIndex = [self numericCompaction:codewords codeIndex:codeIndex result:result];
                if (codeIndex < 0) {
                    if (error) *error = AGXFormatErrorInstance();
                    return nil;
                }
                break;
            case AGX_PDF417_ECI_CHARSET: {
                encoding = [AGXCharacterSetECI characterSetECIByValue:codewords.array[codeIndex++]].encoding;
                break;
            }
            case AGX_PDF417_ECI_GENERAL_PURPOSE:
                // Can't do anything with generic ECI; skip its 2 characters
                codeIndex += 2;
                break;
            case AGX_PDF417_ECI_USER_DEFINED:
                // Can't do anything with user ECI; skip its 1 character
                codeIndex ++;
                break;
            case AGX_PDF417_BEGIN_MACRO_PDF417_CONTROL_BLOCK:
                codeIndex = [self decodeMacroBlock:codewords codeIndex:codeIndex];
                if (codeIndex < 0) {
                    if (error) *error = AGXFormatErrorInstance();
                    return nil;
                }
                break;
            case AGX_PDF417_BEGIN_MACRO_PDF417_OPTIONAL_FIELD:
            case AGX_PDF417_MACRO_PDF417_TERMINATOR:
                // Should not see these outside a macro block
                if (error) *error = AGXFormatErrorInstance();
                return nil;
            default:
                // Default to text compaction. During testing numerous barcodes
                // appeared to be missing the starting mode. In these cases defaulting
                // to text compaction seems to work.
                codeIndex--;
                codeIndex = [self textCompaction:codewords codeIndex:codeIndex result:result];
                break;
        }
        if (codeIndex < codewords.length) {
            code = codewords.array[codeIndex++];
        } else {
            if (error) *error = AGXFormatErrorInstance();
            return nil;
        }
    }
    if ([result length] == 0) {
        if (error) *error = AGXFormatErrorInstance();
        return nil;
    }
    return [AGXDecoderResult resultWithText:result ecLevel:ecLevel];
}

+ (int)textCompaction:(AGXIntArray *)codewords codeIndex:(int)codeIndex result:(NSMutableString *)result {
    // 2 character per codeword
    AGXIntArray *textCompactionData = [AGXIntArray intArrayWithLength:(codewords.array[0] - codeIndex) * 2];
    // Used to hold the byte compaction value if there is a mode shift
    AGXIntArray *byteCompactionData = [AGXIntArray intArrayWithLength:(codewords.array[0] - codeIndex) * 2];

    int index = 0;
    BOOL end = NO;
    while ((codeIndex < codewords.array[0]) && !end) {
        int code = codewords.array[codeIndex++];
        if (code < AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
            textCompactionData.array[index] = code / 30;
            textCompactionData.array[index + 1] = code % 30;
            index += 2;
        } else {
            switch (code) {
                case AGX_PDF417_TEXT_COMPACTION_MODE_LATCH:
                    // reinitialize text compaction mode to alpha sub mode
                    textCompactionData.array[index++] = AGX_PDF417_TEXT_COMPACTION_MODE_LATCH;
                    break;
                case AGX_PDF417_BYTE_COMPACTION_MODE_LATCH:
                case AGX_PDF417_BYTE_COMPACTION_MODE_LATCH_6:
                case AGX_PDF417_NUMERIC_COMPACTION_MODE_LATCH:
                case AGX_PDF417_BEGIN_MACRO_PDF417_CONTROL_BLOCK:
                case AGX_PDF417_BEGIN_MACRO_PDF417_OPTIONAL_FIELD:
                case AGX_PDF417_MACRO_PDF417_TERMINATOR:
                    codeIndex--;
                    end = YES;
                    break;
                case AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE:
                    // The Mode Shift codeword 913 shall cause a temporary
                    // switch from Text Compaction mode to Byte Compaction mode.
                    // This switch shall be in effect for only the next codeword,
                    // after which the mode shall revert to the prevailing sub-mode
                    // of the Text Compaction mode. Codeword 913 is only available
                    // in Text Compaction mode; its use is described in 5.4.2.4.
                    textCompactionData.array[index] = AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE;
                    code = codewords.array[codeIndex++];
                    byteCompactionData.array[index] = code;
                    index++;
                    break;
            }
        }
    }
    
    [self decodeTextCompaction:textCompactionData byteCompactionData:byteCompactionData length:index result:result];
    return codeIndex;
}

+ (void)decodeTextCompaction:(AGXIntArray *)textCompactionData byteCompactionData:(AGXIntArray *)byteCompactionData length:(unsigned int)length result:(NSMutableString *)result {
    // Beginning from an initial state of the Alpha sub-mode
    // The default compaction mode for PDF417 in effect at the start of each symbol shall always be Text
    // Compaction mode Alpha sub-mode (uppercase alphabetic). A latch codeword from another mode to the Text
    // Compaction mode shall always switch to the Text Compaction Alpha sub-mode.
    AGXPDF417Mode subMode = AGXPDF417ModeAlpha;
    AGXPDF417Mode priorToShiftMode = AGXPDF417ModeAlpha;
    int i = 0;
    while (i < length) {
        int subModeCh = textCompactionData.array[i];
        unichar ch = 0;
        switch (subMode) {
            case AGXPDF417ModeAlpha:
                // Alpha (uppercase alphabetic)
                if (subModeCh < 26) {
                    // Upper case Alpha Character
                    ch = (unichar)('A' + subModeCh);
                } else {
                    if (subModeCh == 26) {
                        ch = ' ';
                    } else if (subModeCh == AGX_PDF417_LL) {
                        subMode = AGXPDF417ModeLower;
                    } else if (subModeCh == AGX_PDF417_ML) {
                        subMode = AGXPDF417ModeMixed;
                    } else if (subModeCh == AGX_PDF417_PS) {
                        // Shift to punctuation
                        priorToShiftMode = subMode;
                        subMode = AGXPDF417ModePunctShift;
                    } else if (subModeCh == AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        // TODO Does this need to use the current character encoding? See other occurrences below
                        [result appendFormat:@"%C", (unichar)byteCompactionData.array[i]];
                    } else if (subModeCh == AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
                        subMode = AGXPDF417ModeAlpha;
                    }
                }
                break;

            case AGXPDF417ModeLower:
                // Lower (lowercase alphabetic)
                if (subModeCh < 26) {
                    ch = (unichar)('a' + subModeCh);
                } else {
                    if (subModeCh == 26) {
                        ch = ' ';
                    } else if (subModeCh == AGX_PDF417_AS) {
                        // Shift to alpha
                        priorToShiftMode = subMode;
                        subMode = AGXPDF417ModeAlphaShift;
                    } else if (subModeCh == AGX_PDF417_ML) {
                        subMode = AGXPDF417ModeMixed;
                    } else if (subModeCh == AGX_PDF417_PS) {
                        // Shift to punctuation
                        priorToShiftMode = subMode;
                        subMode = AGXPDF417ModePunctShift;
                    } else if (subModeCh == AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        [result appendFormat:@"%C", (unichar)byteCompactionData.array[i]];
                    } else if (subModeCh == AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
                        subMode = AGXPDF417ModeAlpha;
                    }
                }
                break;

            case AGXPDF417ModeMixed:
                // Mixed (numeric and some punctuation)
                if (subModeCh < AGX_PDF417_PL) {
                    ch = AGX_PDF417_MIXED_CHARS[subModeCh];
                } else {
                    if (subModeCh == AGX_PDF417_PL) {
                        subMode = AGXPDF417ModePunct;
                    } else if (subModeCh == 26) {
                        ch = ' ';
                    } else if (subModeCh == AGX_PDF417_LL) {
                        subMode = AGXPDF417ModeLower;
                    } else if (subModeCh == AGX_PDF417_AL) {
                        subMode = AGXPDF417ModeAlpha;
                    } else if (subModeCh == AGX_PDF417_PS) {
                        // Shift to punctuation
                        priorToShiftMode = subMode;
                        subMode = AGXPDF417ModePunctShift;
                    } else if (subModeCh == AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        [result appendFormat:@"%C", (unichar)byteCompactionData.array[i]];
                    } else if (subModeCh == AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
                        subMode = AGXPDF417ModeAlpha;
                    }
                }
                break;

            case AGXPDF417ModePunct:
                // Punctuation
                if (subModeCh < AGX_PDF417_PAL) {
                    ch = AGX_PDF417_PUNCT_CHARS[subModeCh];
                } else {
                    if (subModeCh == AGX_PDF417_PAL) {
                        subMode = AGXPDF417ModeAlpha;
                    } else if (subModeCh == AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        [result appendFormat:@"%C", (unichar)byteCompactionData.array[i]];
                    } else if (AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
                        subMode = AGXPDF417ModeAlpha;
                    }
                }
                break;

            case AGXPDF417ModeAlphaShift:
                // Restore sub-mode
                subMode = priorToShiftMode;
                if (subModeCh < 26) {
                    ch = (unichar)('A' + subModeCh);
                } else {
                    if (subModeCh == 26) {
                        ch = ' ';
                    } else if (subModeCh == AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
                        subMode = AGXPDF417ModeAlpha;
                    }
                }
                break;
                
            case AGXPDF417ModePunctShift:
                // Restore sub-mode
                subMode = priorToShiftMode;
                if (subModeCh < AGX_PDF417_PAL) {
                    ch = AGX_PDF417_PUNCT_CHARS[subModeCh];
                } else {
                    if (subModeCh == AGX_PDF417_PAL) {
                        subMode = AGXPDF417ModeAlpha;
                    } else if (subModeCh == AGX_PDF417_MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        // PS before Shift-to-Byte is used as a padding character,
                        // see 5.4.2.4 of the specification
                        [result appendFormat:@"%C", (unichar)byteCompactionData.array[i]];
                    } else if (subModeCh == AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
                        subMode = AGXPDF417ModeAlpha;
                    }
                }
                break;
        }
        if (ch != 0) {
            // Append decoded character to result
            [result appendFormat:@"%C", ch];
        }
        i++;
    }
}

+ (int)byteCompaction:(int)mode
            codewords:(AGXIntArray *)codewords
             encoding:(NSStringEncoding)encoding
            codeIndex:(int)codeIndex
               result:(NSMutableString *)result {
    NSMutableData *decodedBytes = [NSMutableData data];
    if (mode == AGX_PDF417_BYTE_COMPACTION_MODE_LATCH) {
        // Total number of Byte Compaction characters to be encoded
        // is not a multiple of 6
        int count = 0;
        long long value = 0;
        AGXIntArray *byteCompactedCodewords = [AGXIntArray intArrayWithLength:6];
        BOOL end = NO;
        int nextCode = codewords.array[codeIndex++];
        while ((codeIndex < codewords.array[0]) && !end) {
            byteCompactedCodewords.array[count++] = nextCode;
            // Base 900
            value = 900 * value + nextCode;
            nextCode = codewords.array[codeIndex++];
            // perhaps it should be ok to check only nextCode >= TEXT_COMPACTION_MODE_LATCH
            if (nextCode == AGX_PDF417_TEXT_COMPACTION_MODE_LATCH ||
                nextCode == AGX_PDF417_BYTE_COMPACTION_MODE_LATCH ||
                nextCode == AGX_PDF417_NUMERIC_COMPACTION_MODE_LATCH ||
                nextCode == AGX_PDF417_BYTE_COMPACTION_MODE_LATCH_6 ||
                nextCode == AGX_PDF417_BEGIN_MACRO_PDF417_CONTROL_BLOCK ||
                nextCode == AGX_PDF417_BEGIN_MACRO_PDF417_OPTIONAL_FIELD ||
                nextCode == AGX_PDF417_MACRO_PDF417_TERMINATOR) {
                codeIndex--;
                end = YES;
            } else {
                if ((count % 5 == 0) && (count > 0)) {
                    // Decode every 5 codewords
                    // Convert to Base 256
                    for (int j = 0; j < 6; ++j) {
                        int8_t byte = (int8_t) (value >> (8 * (5 - j)));
                        [decodedBytes appendBytes:&byte length:1];
                    }
                    value = 0;
                    count = 0;
                }
            }
        }

        // if the end of all codewords is reached the last codeword needs to be added
        if (codeIndex == codewords.array[0] && nextCode < AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
            byteCompactedCodewords.array[count++] = nextCode;
        }

        // If Byte Compaction mode is invoked with codeword 901,
        // the last group of codewords is interpreted directly
        // as one byte per codeword, without compaction.
        for (int i = 0; i < count; i++) {
            int8_t byte = (int8_t)byteCompactedCodewords.array[i];
            [decodedBytes appendBytes:&byte length:1];
        }
    } else if (mode == AGX_PDF417_BYTE_COMPACTION_MODE_LATCH_6) {
        // Total number of Byte Compaction characters to be encoded
        // is an integer multiple of 6
        int count = 0;
        long long value = 0;
        BOOL end = NO;
        while (codeIndex < codewords.array[0] && !end) {
            int code = codewords.array[codeIndex++];
            if (code < AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
                count++;
                // Base 900
                value = 900 * value + code;
            } else {
                if (code == AGX_PDF417_TEXT_COMPACTION_MODE_LATCH ||
                    code == AGX_PDF417_BYTE_COMPACTION_MODE_LATCH ||
                    code == AGX_PDF417_NUMERIC_COMPACTION_MODE_LATCH ||
                    code == AGX_PDF417_BYTE_COMPACTION_MODE_LATCH_6 ||
                    code == AGX_PDF417_BEGIN_MACRO_PDF417_CONTROL_BLOCK ||
                    code == AGX_PDF417_BEGIN_MACRO_PDF417_OPTIONAL_FIELD ||
                    code == AGX_PDF417_MACRO_PDF417_TERMINATOR) {
                    codeIndex--;
                    end = YES;
                }
            }
            if ((count % 5 == 0) && (count > 0)) {
                // Decode every 5 codewords
                // Convert to Base 256
                for (int j = 0; j < 6; ++j) {
                    int8_t byte = (int8_t) (value >> (8 * (5 - j)));
                    [decodedBytes appendBytes:&byte length:1];
                }
                value = 0;
                count = 0;
            }
        }
    }
    [result appendString:[NSString stringWithData:decodedBytes encoding:encoding]];
    return codeIndex;
}

+ (int)numericCompaction:(AGXIntArray *)codewords codeIndex:(int)codeIndex result:(NSMutableString *)result {
    int count = 0;
    BOOL end = NO;

    AGXIntArray *numericCodewords = [AGXIntArray intArrayWithLength:AGX_PDF417_MAX_NUMERIC_CODEWORDS];

    while (codeIndex < codewords.array[0] && !end) {
        int code = codewords.array[codeIndex++];
        if (codeIndex == codewords.array[0]) {
            end = YES;
        }
        if (code < AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
            numericCodewords.array[count] = code;
            count++;
        } else {
            if (code == AGX_PDF417_TEXT_COMPACTION_MODE_LATCH ||
                code == AGX_PDF417_BYTE_COMPACTION_MODE_LATCH ||
                code == AGX_PDF417_BYTE_COMPACTION_MODE_LATCH_6 ||
                code == AGX_PDF417_BEGIN_MACRO_PDF417_CONTROL_BLOCK ||
                code == AGX_PDF417_BEGIN_MACRO_PDF417_OPTIONAL_FIELD ||
                code == AGX_PDF417_MACRO_PDF417_TERMINATOR) {
                codeIndex--;
                end = YES;
            }
        }
        if (count % AGX_PDF417_MAX_NUMERIC_CODEWORDS == 0 ||
            code == AGX_PDF417_NUMERIC_COMPACTION_MODE_LATCH ||
            end) {
            // Re-invoking Numeric Compaction mode (by using codeword 902
            // while in Numeric Compaction mode) serves  to terminate the
            // current Numeric Compaction mode grouping as described in 5.4.4.2,
            // and then to start a new one grouping.
            if (count > 0) {
                NSString *s = [self decodeBase900toBase10:numericCodewords count:count];
                if (s == nil) {
                    return -1;
                }
                [result appendString:s];
                count = 0;
            }
        }
    }
    return codeIndex;
}

+ (int)decodeMacroBlock:(AGXIntArray *)codewords codeIndex:(int)codeIndex {
    if (codeIndex + AGX_PDF417_NUMBER_OF_SEQUENCE_CODEWORDS > codewords.array[0]) {
        // we must have at least two bytes left for the segment index
        return -1;
    }
    AGXIntArray *segmentIndexArray = [AGXIntArray intArrayWithLength:AGX_PDF417_NUMBER_OF_SEQUENCE_CODEWORDS];
    for (int i = 0; i < AGX_PDF417_NUMBER_OF_SEQUENCE_CODEWORDS; i++, codeIndex++) {
        segmentIndexArray.array[i] = codewords.array[codeIndex];
    }

    NSMutableString *fileId = [NSMutableString string];
    codeIndex = [self textCompaction:codewords codeIndex:codeIndex result:fileId];

    if (codewords.array[codeIndex] == AGX_PDF417_BEGIN_MACRO_PDF417_OPTIONAL_FIELD) {
        codeIndex++;
        NSMutableArray *additionalOptionCodeWords = [NSMutableArray array];

        BOOL end = NO;
        while ((codeIndex < codewords.array[0]) && !end) {
            int code = codewords.array[codeIndex++];
            if (code < AGX_PDF417_TEXT_COMPACTION_MODE_LATCH) {
                [additionalOptionCodeWords addObject:@(code)];
            } else {
                switch (code) {
                    case AGX_PDF417_MACRO_PDF417_TERMINATOR:
                        codeIndex++;
                        end = YES;
                        break;
                    default:
                        return -1;
                }
            }
        }

    } else if (codewords.array[codeIndex] == AGX_PDF417_MACRO_PDF417_TERMINATOR) {
        codeIndex++;
    }
    return codeIndex;
}

/**
 * Convert a list of Numeric Compacted codewords from Base 900 to Base 10.
 *
 * @param codewords The array of codewords
 * @param count     The number of codewords
 * @return The decoded string representing the Numeric data.
 */
/*
 EXAMPLE
 Encode the fifteen digit numeric string 000213298174000
 Prefix the numeric string with a 1 and set the initial value of
 t = 1 000 213 298 174 000
 Calculate codeword 0
 d0 = 1 000 213 298 174 000 mod 900 = 200

 t = 1 000 213 298 174 000 div 900 = 1 111 348 109 082
 Calculate codeword 1
 d1 = 1 111 348 109 082 mod 900 = 282

 t = 1 111 348 109 082 div 900 = 1 234 831 232
 Calculate codeword 2
 d2 = 1 234 831 232 mod 900 = 632

 t = 1 234 831 232 div 900 = 1 372 034
 Calculate codeword 3
 d3 = 1 372 034 mod 900 = 434

 t = 1 372 034 div 900 = 1 524
 Calculate codeword 4u
 d4 = 1 524 mod 900 = 624

 t = 1 524 div 900 = 1
 Calculate codeword 5
 d5 = 1 mod 900 = 1
 t = 1 div 900 = 0
 Codeword sequence is: 1, 624, 434, 632, 282, 200

 Decode the above codewords involves
 1 x 900 power of 5 + 624 x 900 power of 4 + 434 x 900 power of 3 +
 632 x 900 power of 2 + 282 x 900 power of 1 + 200 x 900 power of 0 = 1000213298174000

 Remove leading 1 =>  Result is 000213298174000
 */
+ (NSString *)decodeBase900toBase10:(AGXIntArray *)codewords count:(int)count {
    NSDecimalNumber *result = [NSDecimalNumber zero];
    for (int i = 0; i < count; i++) {
        result = [result decimalNumberByAdding:[AGX_PDF417_EXP900[count - i - 1] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[@(codewords.array[i]) decimalValue]]]];
    }
    NSString *resultString = [result stringValue];
    if (![resultString hasPrefix:@"1"]) {
        return nil;
    }
    return [resultString substringFromIndex:1];
}

@end