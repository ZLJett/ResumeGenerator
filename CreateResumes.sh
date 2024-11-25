#!/usr/bin/env bash

# Program to setup and run Resume 'website' with option to automatically Print-to-PDF once site is setup.
# Note: This program is designed to run at the project root and will not function correctly if run in a 
# different directory
# Options:
#  --help                           Display this help message
#  -i, --ignore                     Ignore resume DIRS when generating and use default directories instead. ARG: comma separated list of resume directories to ignore, e.g. '_data,_templates,_sass'
#  -p, --print                      Print-to-PDF resume, then end program
#  -r, --replace-main-stylesheet    Replace default resume stylesheet, 'defaultStyle.scss', with FILE. ARG: FILE is the name of a stylesheet in the root '_sass' directory without extension, e.g. 'defaultStyle'
#  -s, --source                     Set source resume directory to DIR. ARG: DIR is the name of a directory in the '_resumes' directory, e.g. '_testResume'


# Function to display script usage
help() {
    echo "This program is designed to run at the project root and will not function correctly if run in a different directory"
    echo "Usage: $0 [--help] [-i DIRS, --ignore DIRS] [-p, --print] [-r FILE, --replace-main-stylesheet FILE] [-s DIR, --source DIR]"
    echo "Options:"
    echo " --help                           Display this help message"
    echo " -i, --ignore                     Ignore resume DIRS when generating and use default directories instead. ARG: comma separated list of resume directories to ignore, e.g. '_data,_templates,_sass'"
    echo " -p, --print                      Print-to-PDF resume, then end program"
    echo " -r, --replace-main-stylesheet    Replace default resume stylesheet, 'defaultStyle.scss', with FILE. ARG: FILE is the name of a stylesheet in the root '_sass' directory without extension, e.g. 'defaultStyle'"
    echo " -s, --source                     Set source resume directory to DIR. ARG: DIR is the name of a directory in the '_resumes' directory, e.g. '_testResume'"
}

missingIgnoreDirsMsg="CreateResumes.sh: Must provide argument to flag: [-i DIRS, --ignore DIRS]"
missingReplacementStyleMsg="CreateResumes.sh: Must provide argument to flag: [-r FILE, --replace-main-stylesheet FILE]"
missingSourceMsg="CreateResumes.sh: Must provide argument to flag: [-s DIR, --source DIR]"

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            help
            exit 0
            ;;
        -i|--ignore)
            if [ "$2" == "" ] ; then echo "${missingIgnoreDirsMsg}" ; help ; exit 1 ; fi
            IGNOREDIRS="true"
            IGNOREDIRSLIST="$2"
            shift
            shift
            ;;
        -p|--print)
            PRINT="true"
            shift
            ;;
        -r|--replace-main-stylesheet)
            if [ "$2" == "" ] ; then echo "${missingReplacementStyleMsg}" ; help ; exit 1 ; fi
            REPLACEDEFAULTSTYLE="true"
            REPLACEMENTSTYLESHEET="$2"
            shift
            shift
            ;;
        -s|--source)
            if [ "$2" == "" ] ; then echo "${missingSourceMsg}" ; help ; exit 1 ; fi
            SOURCE="$2"
            shift
            shift
            ;;
        -*|--*)
            echo "CreateResumes.sh: Unknown option: $1"
            help
            exit 1
            ;;
        *)
            echo "CreateResumes.sh: Invalid option: $1"
            help
            exit 1
            ;;
    esac
done

# Set which resume directories to ignore when generating resume
RESUMEADDITIONALSTYLES="true" # Unlike the other two where falsity is all that matters this is check for both true/false
if [ "${IGNOREDIRS}" == "true" ]; then
    IFS=',' read -ra ignoredResumeDir <<< "$IGNOREDIRSLIST"
    for i in "${ignoredResumeDir[@]}" ; do
        case $i in
        _data) 
            RESUMEDATA="false"
            echo "CreateResumes.sh: Resume '_data' directory files ignored, default '_data' directory files used instead"
            ;;
        _includes)
            RESUMETEMPLATES="false"
            echo "CreateResumes.sh: Resume '_includes' directory files ignored, default '_includes' directory files used instead"
            ;;
        _sass)
            RESUMEADDITIONALSTYLES="false"
            echo "CreateResumes.sh: Resume '_sass' directory files ignored, default '_sass' directory files used instead"
            ;;
        *)
            ;;
        esac
    done
fi

# Turn source resume directory argument into full relative filepath to resume directory
resumeDirectory="_resumes/"${SOURCE}


### Data and Template Config Variables Setup ###
# Create "modified_resume_data: []" config variable, and add all resume specific Data files,
# i.e. modified Data, to the variable. Note: Values MUST be strings, e.g. ["contactInfoData"]
resumeDataDirectory=${resumeDirectory}"/_data/"
modifiedResumeData="modified_resume_data: ["
if [ "${RESUMEDATA}" == "false" ]; then
    # Set modified resume data list so default data will be used instead
    modifiedResumeData+="]"
else
    # Generate list of modified resume data files
    for file in $(find $resumeDataDirectory -name '*.yml') ; do
    # Takes: "_resumes/_testResume/_data/educationData.yml" to "educationData"
    dataFileStripped="$(basename -s .yml $file)" 
    modifiedResumeData+="\"${dataFileStripped}\","
    done
    # If config variable list empty cap with "]" otherwise replace trailing string with "]"
    if [ "${modifiedResumeData: -1}" == "[" ]; then
        modifiedResumeData+="]"
    else 
        modifiedResumeData=${modifiedResumeData/%,/]}
    fi
fi

# Create "modified_resume_templates: []" config variable, and add all resume specific Templates files,
# i.e. modified Templates, to the variable
resumeIncludesDirectory=${resumeDirectory}"/_includes/"
modifiedResumeTemplates="modified_resume_templates: ["
if [ "${RESUMETEMPLATES}" == "false" ]; then
    # Set modified resume template list so default templates will be used instead
    modifiedResumeTemplates+="]"
else
    # Generate list of modified resume template files
    for file in $(find $resumeIncludesDirectory -name '*.html') ; do
    # Takes: "_resumes/_testResume/_includes/resumeTitleTemplate.html" to "resumeTitleTemplate"
    templateFileStripped="$(basename -s .html $file)" 
    modifiedResumeTemplates+="${templateFileStripped},"
    done
    # If config variable list empty cap with "]" otherwise replace trailing string with "]"
    if [ "${modifiedResumeTemplates: -1}" == "[" ]; then
        modifiedResumeTemplates+="]"
    else 
        modifiedResumeTemplates=${modifiedResumeTemplates/%,/]}
    fi
fi

### Style Config Variables Setup ###
# Create "replace_default_style: " and "main_stylesheet: " config variables based on if the flag
# [-r FILE, --replace-main-stylesheet FILE] is set, otherwise set "replace_default_style: " to 
# default of "false" 
if [ "${REPLACEDEFAULTSTYLE}" == "true" ]; then
    # Set so default stylesheet will be used
    replaceDefaultStyleSetting+="replace_default_style: true"
    mainStyle="main_stylesheet: ${REPLACEMENTSTYLESHEET}"
else 
    replaceDefaultStyleSetting+="replace_default_style: false"
    mainStyle="main_stylesheet: defaultStyle"
fi

# Create three additional styles config variables "additional_styles: ", "sass: load_paths: []", and
# "additional_stylesheets: []"
if [ "${RESUMEADDITIONALSTYLES}" == "false" ]; then
    # Set additional styles config variables so defaults will be used instead
    additionalStylesSetting="additional_styles: false"
    additionalStylesheets="additional_stylesheets: []"
else 
    additionalStylesSetting="additional_styles: true"
    # Create "additionalStylesheets: " config variable, and add resume specific stylesheets in the resume's
    # _sass directory as objects to the list. Example: - {additionalStylesheet: additionalStyleName}
    resumeSassDirectory=${resumeDirectory}"/_sass/"
    additionalStylesheets="additional_stylesheets: ["
    # Generate list of resume stylesheets
    for file in $(find $resumeSassDirectory -name '*.scss' | sort ) ; do
    # Takes: "_resumes/_testResume/_sass/additionalStyle.scss" to "additionalStyle"
    stylesheetStripped="$(basename -s .scss $file)" 
    additionalStylesheets+="${stylesheetStripped},"
    done
    # If config variable list empty cap with "]" otherwise replace trailing string with "]"
    if [ "${additionalStylesheets: -1}" == "[" ]; then
        additionalStylesheets+="]"
    else 
        additionalStylesheets=${additionalStylesheets/%,/]}
    fi
fi

# Create "sass: load_paths: []" config variable if so that either the replacement main stylesheet can
# or the additional stylesheets can be pulled from the resume specific _sass directory. 
# Variable contains filepath to the resume specific _sass directory. 
# Example: load_paths: [_resumes/_testResume/_sass]
if [ "${REPLACEDEFAULTSTYLE}" == "true" ] || [ "${RESUMEADDITIONALSTYLES}" == "true" ]; then
    # The backslashes on each forward slash and \s characters are to conform this input for insertion
    # i.e. the sed command's requirements
    resumeStyleDirectory="_resumes\/"${SOURCE}"\/_sass"
    styleLoadPath="  load_paths: ["${resumeStyleDirectory}"]"
else 
    styleLoadPath="  load_paths: []"
fi


### Add Created Config Variables to Resume _config File ###
resumeDefaultConfigFile=${resumeDirectory}"/_configs/_config.yml"

# Set source resume directory, i.e. the directory this resume will be generated from by
# setting the "include: " config variable's "# Resume Source Directory" to the directory
# selected by the user with the [-s DIR, --source DIR] flag
resumeSourceLine="- ${SOURCE}    # Resume Source Directory"
sed -i "s/- .*\# Resume Source Directory/${resumeSourceLine}/" ${resumeDefaultConfigFile}

# Replace the existing config variable, "modified_resume_data: []" in the standard resume 
# _config file with one containing the resume specific Data files
sed -i "s/modified_resume_data: .*\]/${modifiedResumeData}/" ${resumeDefaultConfigFile}

# Replace the existing config variable, "modified_resume_templates: []" in the standard 
# resume _config file with one containing the resume specific Templates files
sed -i "s/modified_resume_templates: .*\]/${modifiedResumeTemplates}/" ${resumeDefaultConfigFile}

# Replace the existing config variable, "replace_default_style: " in the standard 
# resume _config file with one containing user input or default value
sed -i "s/replace_default_style: .*/${replaceDefaultStyleSetting}/" ${resumeDefaultConfigFile}

# Replace the existing config variable, "main_stylesheet: " in the standard 
# resume _config file with one containing the new main stylesheet
sed -i "s/main_stylesheet: .*/${mainStyle}/" ${resumeDefaultConfigFile}

# Replace the existing config variable, "additional_styles: " in the standard 
# resume _config file with one containing user input or default value
sed -i "s/additional_styles: .*/${additionalStylesSetting}/" ${resumeDefaultConfigFile}

# Replace the existing config variable, "sass: load_paths: []" in the standard 
# resume _config file with one containing the resume specific _sass directory filepath
sed -i "s/\s\sload_paths: .*\]/${styleLoadPath}/" ${resumeDefaultConfigFile}

# Replace the existing config variable, "additional_stylesheets: []" in the standard 
# resume _config file with one containing the resume specific additional stylesheets files
sed -i "s/additional_stylesheets: .*\]/${additionalStylesheets}/" ${resumeDefaultConfigFile}


### Setup --config flag Argument for Jekyll ###
# Setup the configs argument for running the server (i.e "jekyll serve"), with first addition
# being the root _config.yml file
configsArg="_config.yml"

# Add all Resume specific _config files to config argument, e.g. standard Resume _config file
resumeConfigDirectory=${resumeDirectory}"/_configs/"
for file in $(find $resumeConfigDirectory -name '*.yml') ; do
    configsArg+=",${file}" # Note: there are no spaces between additional config files, only commas
done

# Add all Resume specific Data Files, i.e. modified Data Files, to config argument
# Note that in reality these are extra config files, with data in a different format 
# from my regular data files
for file in $(find $resumeDataDirectory -name '*.yml') ; do
    configsArg+=",${file}" # Note: there are no spaces between additional config files, only commas
done


### Print-to-PDF Setup ###
# Set default Resume output directory and filename for Print-to-PDF
# Default resume name is name of resume directory with underscore removed and first 
# letter capitalized with date/time added, e.g. TestResume_24-10-30_05:38:17
defaultResumeName="${SOURCE:1}"
date=$(date '+%y-%m-%d_%H-%M-%S')
defaultResumeName="${defaultResumeName^}_"${date}
targetFile=${resumeDirectory}"/_outputResumes/"${defaultResumeName}".pdf"

# Function to run Print-to-PDF once server is running 
printPdf() {
    echo "[${date}] CreateResumes.sh:  Start Print"
    # Sleep is intended to delay printing until after the server is fully setup and running
    sleep 2
    # Port 4000 is the Jekyll default 
    google-chrome --headless --disable-gpu --virtual-time-budget=10000 --print-to-pdf="${targetFile}" --no-pdf-header-footer http://127.0.0.1:4000/
    echo "[${date}] CreateResumes.sh:  End Print "
}


### Generate Resume ###
if [ "$PRINT" == "true" ]; then
    echo "[${date}] CreateResumes.sh:  Launch Server"
    bundle exec jekyll serve --config ${configsArg} & printPdf & PID=$!;
    # Wait for printPdf finish before ending server process
    wait $PID
    # Sleep gives program just enough time to finish cleaning up so it can shutdown properly 
    sleep 1
    # The % refers to the current job, i.e. the last background job 
    kill -SIGINT %
    echo "[${date}] CreateResumes.sh:  Shutdown Server"
else 
    echo "[${date}] CreateResumes.sh:  Launch Server"
    # --livereload option allows changes to resume to show up without a server restart
    bundle exec jekyll serve --livereload --config ${configsArg}
    # Must manually enter: CRTL + C, to shut down a Jekyll server
    echo "[${date}] CreateResumes.sh:  Shutdown Server"
fi
