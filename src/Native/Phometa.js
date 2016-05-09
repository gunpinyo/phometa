Elm.Native = Elm.Native || {};
Elm.Native.Phometa = {};
Elm.Native.Phometa.make = function(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Phometa = localRuntime.Native.Phometa || {};
    if (localRuntime.Native.Phometa.values)
    {
        return localRuntime.Native.Phometa.values;
    }

    function isValidRegexPattern(str) {
        try {
            new RegExp(str, 'g');
            return true;
        } catch (e) {
            return false;
        }
    }

    function regexToString(re) {
        return re.toString();
    }

    return localRuntime.Native.Phometa.values = {
        isValidRegexPattern: isValidRegexPattern,
        regexToString: regexToString
    };
};
