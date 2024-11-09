#!/usr/bin/env bash

# Program to setup and run Resume 'website' with option to automatically Print-to-PDF once site is setup.
# Note: This program is designed to run at the project root and will not function correctly if run in a 
# different directory
# Options:
#  -h, --help      Display this help message
#  -s, --source    Source resume directory, DIR, in project '_resumes' directory, e.g. '_testResume'
#  -p, --print     Print-to-PDF resume into resume's '_outputResumes' directory, then end program


# Function to display script usage
help() {
    echo "This program is designed to run at the project root and will not function correctly if run in a different directory"
    echo "Usage: $0 [-h, --help] [-s DIR, --source DIR] [-p, --print]"
    echo "Options:"
    echo " -h, --help      Display this help message"
    echo " -s, --source    Source resume directory, DIR, in project '_resumes' directory, e.g. '_testResume'"
    echo " -p, --print     Print-to-PDF resume, then end program"
}


while [[ $# -gt 0 ]]; do
    case $1 in
        -h | --help)
            help
            exit 0
            ;;
        -s|--source)
            SOURCE="$2"
            shift
            shift
            ;;
        -p|--print)
            PRINT="true"
            shift
            ;;
        -*|--*)
            echo "CreateResumes.sh: Unknown option $1"
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

# Turn source resume directory argument into full relative filepath to resume directory
resumeDirectory="_resumes/"${SOURCE}


# Create "modifiedResumeData: []" config variable, and add all resume specific Data files, 
# i.e. modified Data, to the variable. Note: Values MUST be strings, e.g. ["contactInfoData"]
resumeDataDirectory=${resumeDirectory}"/_data/"
modifiedResumeData="modifiedResumeData: ["
for file in $(find $resumeDataDirectory -name '*.yml') ; do
    # Takes: "_resumes/_testResume/_includes/resumeTitleTemplate.html" to "resumeTitleTemplate"
    dataFileStripped="$(basename -s .yml $file)" 
    modifiedResumeData+="\"${dataFileStripped}\","
done

# If config variable list empty cap with "]" otherwise replace trailing string with "]"
if [ "${modifiedResumeData: -1}" == "[" ]; then
    modifiedResumeData+="]"
else 
    modifiedResumeData=${modifiedResumeData/%,/]}
fi

# Create "modifiedResumeTemplates: []" config variable, and add all resume specific Templates files, 
# i.e. modified Templates, to the variable
resumeIncludesDirectory=${resumeDirectory}"/_includes/"
modifiedResumeTemplates="modifiedResumeTemplates: ["
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

# Add any config variables created above to standard Resume _config file
resumeDefaultConfigFile=${resumeDirectory}"/_configs/_config.yml"
# Replace the existing config variable, modifiedResumeData: [] in the Standard Resume 
# _config file with one containing the resume specific Data files
sed -i "s/modifiedResumeData: .*\]/${modifiedResumeData}/" ${resumeDefaultConfigFile}
# Replace the existing config variable, modifiedResumeTemplates: [] in the Standard 
# Resume _config file with one containing the resume specific Templates files
sed -i "s/modifiedResumeTemplates: .*\]/${modifiedResumeTemplates}/" ${resumeDefaultConfigFile}


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


# Set default Resume target directory and filename for Print-to-PDF
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
    google-chrome --headless --disable-gpu --print-to-pdf="${targetFile}" --no-pdf-header-footer http://127.0.0.1:4000/
    echo "[${date}] CreateResumes.sh:  End Print "
}


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
