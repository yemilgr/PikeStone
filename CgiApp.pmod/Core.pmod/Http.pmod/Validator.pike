import ".";

mapping params = ([]);

mapping errorBag = ([]);

object create(mapping|void params)
{
    this_program::params = params;
    return this_object();
}

//validate input agains rules 
mapping validate(mapping inputRules)
{
    mapping validInput = ([]);

    foreach (inputRules; string input; mixed rules) {
        mixed paramValue = params[input];
        
        if (stringp(rules)) { rules = rules / "|"; }

        foreach (rules;; string validator) {
            array validatorParts = validator / ":";
            string validatorFun = validatorParts[0];
            string validatorArg = sizeof(validatorParts) > 1 ? validatorParts[1] : UNDEFINED;

            if (!this_program()[validatorFun]) {
                throw(sprintf("Validator '%s' not exist", validatorFun));
            }

            if (paramValue || isRequired(validatorFun)) {
                if (this_program()[validatorFun](paramValue, validatorArg) == false) {
                    errorBag[input] += ({sprintf("%s must be %s", input, validator)});
                }
            }
        }

        //add as an valid if no validation errors found
        if (zero_type(errorBag[input]) && paramValue) {
            validInput[input] = paramValue;
        }
    }

    return validInput;
}

bool isRequired(string validator)
{
    return validator == "required";
}

bool hasErrors()
{
    return sizeof(this_program::errorBag) > 0;
}

mapping errors()
{
    return this_program::errorBag;
}


/////// Validators //////

bool required(mixed value)
{
    return zero_type(value) || value == UNDEFINED || value == "" ? false : true;
}

bool alpha(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[A-Za-zÀ-ÖØ-öø-ÿ ]*$");
    return regexp->match(value);
}

bool alpha_numeric(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[A-Za-zÀ-ÖØ-öø-ÿ0-9 ]*$");
    return regexp->match(value);
}

bool intp(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[\\-]?[0-9]+$");
    return regexp->match(value);
}

bool floatp(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[\\-]?[0-9]+\\.[0-9]*$");
    return regexp->match(value);
}

bool is_array(mixed value) {
    return arrayp(value);
}

bool base64(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$");
    return regexp->match(value);
}

//@todo not work
bool email(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("[\\w-]+(\\.[\\w-]+)*@[\\w-]+(\\.[\\w-]+)+?[a-z]{1,}$");
    return regexp->match(value);
}

//@todo implement
bool phone(mixed value)
{
    return false;
}

bool dni(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("(([0-9]{8})([-]?)([A-HJ-NP-TV-Z]{1}))");
    return regexp->match(value);
}

bool nie(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[XYZ]{1}[0-9]{7}[A-HJ-NP-TV-Z]{1}$");
    return regexp->match(value);
}

bool nif(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[0-9]{8}[A-HJ-NP-TV-Z]{1}$");
    return regexp->match(value);
}

bool min_length(mixed value, mixed arg)
{
    return sizeof(value) >= (int)arg;
}

bool max_length(mixed value, mixed arg)
{
    return sizeof(value) <= (int)arg;
}

