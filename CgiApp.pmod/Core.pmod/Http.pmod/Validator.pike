import ".";

mapping paramsBag = ([]);

mapping rulesBag = ([]);

mapping inputBag = ([]);

mapping errorBag = ([]);

object create(mapping|void paramsBag)
{
    this_program::paramsBag = paramsBag;
    return this_object();
}

object rules(mapping rules)
{
    this_program::rulesBag = rules;
    return this_object();
}

bool run()
{
    this_program::validate();
    return sizeof(this_program::errorBag) == 0;
}

//validate input agains rules 
mapping validate(mapping|void inputRules)
{
    if (!zero_type(inputRules)) {
        rulesBag = inputRules;
    }

    if (zero_type(rulesBag)) {
        throw("No rules defined");
    }

    foreach (rulesBag; string input; mixed rules) {
        mixed paramValue = paramsBag[input];
        
        if (stringp(rules)) { rules = rules / "|"; }

        foreach (rules;; string validator) {
            array validatorParts = validator / ":";
            string validatorFun = validatorParts[0] + "_validator";
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
            inputBag[input] = paramValue;
        }
    }

    return inputBag;
}

mapping validData()
{
    return inputBag;
}

bool hasErrors()
{
    return sizeof(this_program::errorBag) > 0;
}

mapping errors()
{
    return this_program::errorBag;
}

bool isRequired(string validator)
{
    return validator == "required_validator";
}

/////// Validators //////

bool required_validator(mixed value)
{
    return zero_type(value) || value == UNDEFINED || value == "" ? false : true;
}

bool alpha_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[A-Za-zÀ-ÖØ-öø-ÿ ]*$");
    return regexp->match(value);
}

bool alpha_numeric_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[A-Za-zÀ-ÖØ-öø-ÿ0-9 ]*$");
    return regexp->match(value);
}

bool integer_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[\\-]?[0-9]+$");
    return regexp->match(value);
}

bool float_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[\\-]?[0-9]+\\.[0-9]*$");
    return regexp->match(value);
}

bool array_validator(mixed value) {
    return arrayp(value);
}

bool base64_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$");
    return regexp->match(value);
}

//@todo not work
bool email_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("[\\w-]+(\\.[\\w-]+)*@[\\w-]+(\\.[\\w-]+)+?[a-z]{1,}$");
    return regexp->match(value);
}

//@todo implement
bool phone_validator(mixed value)
{
    return false;
}

bool dni_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("(([0-9]{8})([-]?)([A-HJ-NP-TV-Z]{1}))");
    return regexp->match(value);
}

bool nie_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[XYZ]{1}[0-9]{7}[A-HJ-NP-TV-Z]{1}$");
    return regexp->match(value);
}

bool nif_validator(mixed value)
{
    mixed regexp = Regexp.PCRE.StudiedWidestring("^[0-9]{8}[A-HJ-NP-TV-Z]{1}$");
    return regexp->match(value);
}

bool min_length_validator(mixed value, mixed arg)
{
    return sizeof(value) >= (int)arg;
}

bool max_length_validator(mixed value, mixed arg)
{
    return sizeof(value) <= (int)arg;
}