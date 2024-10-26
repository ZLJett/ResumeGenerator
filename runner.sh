#!/usr/bin/env bash

# Program takes a single argument, the name of the 'target' directory (see root _config.yml), e.g. _targetResume
#      bash runner.sh [target-resume-directory]
# e.g. bash runner.sh _testResume

# Turn argument into filepath to resume directory
resumeDirectory="_resumes/"$1

# Configs argument when run website
configsArg="_config.yml"


# Create modifiedResumeData: []  config variable, and add all resume specific Data files, 
# i.e. modified Data, to the variable. Note: Values MUST be strings, e.g. ["contactInfoData"]
resumeDataDirectory=$resumeDirectory"/_data/"
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


# Create modifiedResumeTemplates: [] config variable, and add all resume specific Templates files, 
# i.e. modified Templates, to the variable
resumeIncludesDirectory=$resumeDirectory"/_includes/"
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


# Add all Resume specific _config files to config argument, such as the standard Resume 
# _config file
resumeConfigDirectory=$resumeDirectory"/_configs/"
for file in $(find $resumeConfigDirectory -name '*.yml') ; do
    configsArg+=",${file}"
done

# Add any config variables created above to standard Resume _config file
resumeDefaultConfigFile=${resumeDirectory}"/_configs/_config.yml"
# Replace the existing config variable, modifiedResumeData: [] in the Standard Resume 
# _config file with one containing the resume specific Data files
sed -i "s/modifiedResumeData: .*\]/${modifiedResumeData}/" ${resumeDefaultConfigFile}
# Replace the existing config variable, modifiedResumeTemplates: [] in the Standard 
# Resume _config file with one containing the resume specific Templates files
sed -i "s/modifiedResumeTemplates: .*\]/${modifiedResumeTemplates}/" ${resumeDefaultConfigFile}

# Add all Resume specific Data Files, i.e. modified Data Files, to config argument
# Note that in reality these are extra config files, with data in a different format 
# from my regular data files
for file in $(find $resumeDataDirectory -name '*.yml') ; do
    configsArg+=",${file}"
done


bundle exec jekyll serve --livereload --config ${configsArg}
