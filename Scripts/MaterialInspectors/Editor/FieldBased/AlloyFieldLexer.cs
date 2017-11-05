// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public abstract class AlloyToken
{
    public string Token;

    protected AlloyToken(string field, AlloyFieldLexer currentLexer) {
        Token = field;
    }
}


public class AlloyCollectionToken : AlloyToken
{
    public List<AlloyToken> SubTokens;

    public const char CollectionOpen = '{';
    public const char CollectionClose = '}';

    public AlloyCollectionToken(string field, AlloyFieldLexer currentLexer)
        : base(field, currentLexer) {


        SubTokens = currentLexer.GenerateTokens(field);
    }
}


public class AlloyArgumentToken : AlloyToken
{
    public const char ArgumentChar = ':';

    public string ArgumentName;
    public AlloyToken ArgumentToken;

    public AlloyArgumentToken(string field, AlloyFieldLexer currentLexer)
        : base(field, currentLexer) {
        int index = field.IndexOf(':');
        ArgumentName = field.Substring(0, index);
        string valueStr = field.Substring(index + 1);


        int outInd;
        ArgumentToken = currentLexer.GenerateToken(valueStr, 0, out outInd);
    }
}


public class AlloyValueToken : AlloyToken
{
    private const string c_true = "True";
    private const string c_false = "False";

    public enum ValueTypeEnum
    {
        Bool,
        Float,
        String
    }


    public ValueTypeEnum ValueType { get; private set; }
    private bool m_boolValue;
    private float m_floatValue;
    private string m_stringValue;


    public bool BoolValue {
        get {
            ExpectType(ValueTypeEnum.Bool);
            return m_boolValue;
        }
    }

    public float FloatValue {
        get {
            ExpectType(ValueTypeEnum.Float);
            return m_floatValue;
        }
    }

    public string StringValue {
        get {
            ExpectType(ValueTypeEnum.String);
            return m_stringValue;
        }
    }

    private void ExpectType(ValueTypeEnum type) {
        if (ValueType != type) {
            Debug.LogError("Cant read " + type + " value from token!");
        }
    }

    public AlloyValueToken(string field, AlloyFieldLexer currentLexer)
        : base(field, currentLexer) {

        if (field == c_true) {
            ValueType = ValueTypeEnum.Bool;
            m_boolValue = true;
            return;
        }


        if (field == c_false) {
            ValueType = ValueTypeEnum.Bool;
            m_boolValue = false;
            return;
        }



        float val;
        if (float.TryParse(field, out val)) {
            ValueType = ValueTypeEnum.Float;
            m_floatValue = val;
            return;
        }

        ValueType = ValueTypeEnum.String;
        m_stringValue = field;
    }
}


//The language defines a few concepts

//A pure token will be intepreted as a value
//MyString -> string value MyString
//True -> bool True
//1.03 -> float 1.03


//A collection token defines a set of tokens
//{1.03f True True {}}

//A argument token defines a name and an associated token
//CollectionArgument:{True, False}





public class AlloyFieldLexer
{
    private AlloyToken[] m_tokens;
    private static char[] s_specialChars = { '.', ':', '_'};


    public List<AlloyToken> GenerateTokens(string parseString) {


        var ret = new List<AlloyToken>();
        int index = 0;

        while (index != -1) {
            var token = GenerateToken(parseString, index, out index);

            if (token == null) {
                break;
            }

            ret.Add(token);
        }

        return ret;
    }

    public AlloyToken GenerateToken(string parseString, int startIndex, out int index) {
        parseString = PreprocessString(parseString);

        for (int i = startIndex; i < parseString.Length; ++i) {
            char c = parseString[i];

            if (c == ' ') {
                continue;
            }

            string token;

            switch (c) {
                case AlloyCollectionToken.CollectionOpen:
                    token = ReadStackedUntil(parseString, i, AlloyCollectionToken.CollectionOpen, AlloyCollectionToken.CollectionClose);
                    index = i + token.Length + 1;
                    return new AlloyCollectionToken(token, this);
            }

            bool charOpen = c == '\'';

            if (char.IsLetterOrDigit(c) || charOpen || s_specialChars.Contains(c)) {
                bool argument;
                token = ReadWord(parseString, i, out argument);
                index = i + token.Length + 1;

                if (charOpen) {
                    ++index;
                }

                if (argument) {
                    return new AlloyArgumentToken(token, this);
                }

                return new AlloyValueToken(token, this);
            }
        }

        index = -1;
        return null;
    }

    private string PreprocessString(string parseString) {
        return parseString.Replace(',', ' ');
    }

    protected string ReadStackedUntil(string parseString, int index, char openC, char closeC) {
        bool found = false;
        int stack = 0;
        int readIndex;

        for (readIndex = index; readIndex < parseString.Length; ++readIndex) {
            char c = parseString[readIndex];

            if (c == openC) {
                ++stack;
            }
            else if (c == closeC) {
                --stack;
            }


            if (stack == 0) {
                found = true;
                break;
            }
        }

        if (!found) {
            Debug.LogError("Parsing fail. Could not find closing char" + closeC);
            Debug.Log(parseString);
            return null;
        }

        return parseString.Substring(index + 1, readIndex - index);
    }

    private string ReadWord(string parseString, int index, out bool isArgument) {
        int readIndex = index;
        bool found = false;
        int stack = 0;

        bool inString = parseString[index] == '\'';

        if (inString) {
            ++index;
        }

        isArgument = false;

    
        for (int i = index; i < parseString.Length; ++i) {
            char curChar = parseString[i];

            readIndex = i;


            if (curChar == ':') {
                isArgument = true;
            }

            if (!inString) {
                if (char.IsLetterOrDigit(curChar) || s_specialChars.Contains(curChar)) {
                    continue;
                }

                if (curChar == AlloyCollectionToken.CollectionOpen) {
                    ++stack;
                    continue;
                }

                if ((curChar == AlloyCollectionToken.CollectionClose) && stack != 0) {
                    --stack;

                    if (stack == 0) {
                        break;
                    }
                }

                if (stack != 0) {
                    continue;
                }
            }
            else {
                if (curChar != '\'') {
                    continue;
                }
            }

            found = true;
            break;
        }

        if (!found) {
            readIndex++;
        }

        string ret = parseString.Substring(index, readIndex - index);


        //TODO: Handle argument:'StringToken'
        /*
        if (found) {

            //if (readIndex < parseString.Length - 1 && parseString[readIndex + 1] == ':') {
                //ret += ReadWord(parseString, readIndex + 2);
            //}
        }
        */

        return ret;
    }
}
