# Jekyll/Liquid Resume Generator 

### Basic Structure Terminology:
Each resume has three layers of content, starting from the top level: 
1. **Elements**, e.g. Education or Projects, which are made up of Sections. Elements are generated from Template files that are stored in the "_includes" directories. 
2. **Section Entries**, e.g. Calculator Webpage or Financial Trade Message Router, each of which is composed of a number of: Data Entries. 
3. **Data Entries**, e.g. Position or Dates. Data is stored in "_data" directories in either .yml or .json files. 

### Basic Function:
This resume generator is designed around several core principles:
1. **DEFAULT content**: All data (_data), templates (_includes), and styles (_sass) in root will generate a 'default' or generic version of themselves from which all other more specific resumes content can be derived. Due to the way the "target directory," i.e. the resume directory, is selected in the root config file, when the resume is generated these default, data, templates, and styles will be used **unless** there are any Resume specific versions of those same files in the resume's directory (see "Auto-Addition of Modified Files" below)  </br>
The two resumes "_baseResume" and "_shortResume" are both intended to be 'generic' resumes generated with only this default data (though "_shortResume" is intended to restrict its contents to keep to a length of a single page). 
2. **Resume Directories**: The resume for each individual company/position is put under the _Resumes directory, e.g. "_baseResume" and "_shortResume". This allows the each resume to keep its own contents, i.e. its own _data, _includes, and _styles separate from all other resumes.
3. **Auto-Addition of Modified Files**: If any new data files or templates are added to a specific resume directory, the resume setup/generation program, CreateResumes.sh, will make sure the modified files replace their default equivalents when the resume is generated. For example, if a different template were created created for the Education Element (i.e. educationTemplate.html) of the file (say one that places the school below the summary) and placed it in that resumes _includes directory under the same name (i.e. educationTemplate.html), it would automatically replace the default Education Element when the resume was generated. </br>
NOTE: The exception to this are styles under the resume's _sass directory, these must be manually added to the root config file. SEE the "Setting up a new Resume Guide" below.
4. **Switches for Minor Changes**: All minor changes to the default structure of a resume are accomplishable with Switches. These changes include, removing Elements from the resume, removing Sections from each each Element and modifying the contents of each Section. Essentially, anything I could forsee wanting to dynamically add or change in the 'default' resume has a switch. </br>
These Switches are YAML Jekyll 'front matter variables' that are placed between the two sets of three dashes (--- ---) at the top of the index.md file of a resume. These can be added, tweaked, or removed at leisure and left in place to preserve the exact structure desired for a resume. ***This means that the index.md file is the main place where a resume's contents will be modified and is effectively another "configuration" file. Hence why the content of the page (i.e. the resume's content) is pushed off to the "defaultContent.html" file in the _includes directory, so that index.md can be mainly devoted to this "configuration" without any distractions***. </br>
For more on Switches see the Switches section below. For the full list of switches see the "ResumeSwitches.yml" file under the "_sampleData" directory. 

**Other Notes**:
1. This system is set up such that the project 'root' is technically where Jekyll is generating the 'website' from, but as there is no index.md file in root it looks in the directories 'included' by the root config file, i.e. the "target directory".

### Resume Switches:
The general design principle of switches is that they are only for items I want to drop, i.e. If I am including an Data Entry at all, it will necessarily have title, position, location, dates, etc. BUT I will want to choose if I want, highlights, links, summary etc. </br>
Hence most switches are for removing default sections (generally prefixed with "skip"), with a handful that add in items that I might want but probably will not most of the time, e.g. like a title on the highlights pat of a Data Entry (generally prefixed with "include"). The third primary category of switches are more complicated YAML objects prefixed with "modified". These Switches allow me to set the exact content of each individual section in an Element, e.g. I can set my most notable project to include everything, while keeping all other projects down to just the essentials to save space. </br>
All switches are YAML Jekyll 'front matter variables' that are placed between the two sets of three dashes (--- ---) at the top of the index.md file of a resume. Thanks to the --livereload Jekyll command these can be changed on the fly by adding/changing a switch in the front matter and saving index.md to apply the change. </br>
A Resume is made up of four layers of Switches: 
1. **Section Data Entry Switches**: These switches control a Section's contents, i.e. its Entry Data, such as a project's summary or highlights. Data switches do not cover Section titles, dates, etc. as it is presumed that if the section is going to be included at all these will necessarily be included. </br>
Default behavior is for all Data Entries in a Section to be included (except for some specific data entries such as the "Education Detail List," which are by default not included). Hence the main switches for changing included Data are in the form of "modifiedSectionEntry" switches, e.g. "modifiedEducation:" where the data that is included in a specific section is hand set with a number of True/False switches, e.g. for Master_of_Arts, "summary: false". Note: that aside from these "modifiedSectionEntry" switches, currently there are only five other Data switches, all of which include 'non-default' Data in **ALL** sections of the Element: "includeMinorProjectSourceLink:", "includeCertLinkAndId:", "includeEducationDetailList:", "includeEducationThesisLink:", and "includeAwardsIssuer:"
2. **Section Layout Switches**: These switches control the layout of **ALL** Sections in an Element, i.e. Master of Arts or Calculator Webpage. The two of the most common of these switches are: "sectionDateDivider:" which sets an alternative separator (rather than the default " &amp;ndash; ") between the start and end date Data Entries, e.g. "to". And "includeBackgroundHighlightsTitle:" which add the title "Highlights:" before the list of highlights. </br>
Default behavior is that all layout features effected by Section Layout Switches are excluded. Hence these switches exist to add to or modify the default sections rather than remove items like the Data switches. </br>
3. **Section Entry Switches**: Each Element has the switch, "skipSectionEntry", that controls what sections are excluded from an Element, e.g. excluding the "Disciplines" Section from the Skill Set Element. Note: that default is to in include all Sections listed in an Element's Data file. </br>
Some Elements have a second switch like this, namely the Contact Info Element has "skipContactWebsite:" and the the Minor Backgrounds Element with "skipMinorProjectCategory:" that exclude other important sub-divisions of data in the Element. 
4. **Resume Content Switches**: By default, **ALL** Elements are included in the Resume and the Template and Data files used to construct each Element are first pulled from the Resume's _includes/_data directories, with any missing made up from the default root _includes/_data directories. Hence these Switches control what Elements are excluded from the Resume, and allow the priority give to Resume's Template/Data files to be overridden, thus replacing the modified Resume Template/Data files with their default counterparts in the root _includes/_data directories.

**Config Resume Content Switch**: The list of all default Resume Elements and their order is set in the  root _config.yml file. SEE the "Resume Contents:" section of "Config File Setup for the new Resume:" below for more on this. 

***For the full list of switches see the "ResumeSwitches.yml" file under the "_sampleData" directory.*** To see exactly what each switch does mechanically, i.e. where they are located in the code, see the Element's template, e.g. _includes/defaultElementTemplates/projectsTemplate.

</br>

## Setting up a new Resume Guide

### Create Resume Files and Directories for the new Resume:
This section covers all additional files that must be created to make a new resume:
***Create Resume Directory***: This directory is placed in the "_resumes" directory and is your "target" directory from which the resume will be generated. </br>
Resume Directory Contents:
1. **_configs directory**: This is where resume specific config information goes. </br>
This **MUST CONTAIN** a file named "_config.yml" as CreateResumes.sh, REQUIRES it. This **MUST CONTAIN** the following two config variables: 1. modifiedResumeTemplates: [],  AND  2. modifiedResumeData: [] (whose values MUST be strings, e.g. ["contactInfoData"]). </br>
**SEE** "_sampleConfigTemplate.yml" in "_sampleData" directory for example of this.
1. **_data and _includes directories**: These contain any modified Data or Template files for the resume. </br>
These **MUST** exist as CreateResumes.sh, **REQUIRES** them; **HOWEVER**, they do NOT need to have any contents. </br>
**NOTE**: In a resume's directory, _data is really a 'config directory' added to the 'website generation' by CreateResumes.sh, and cannot be used at all like the regular _data directory. ***THIS MEANS these files are in YAML and must contain a top level YAML object with the same name as the file, i.e. "skillSetData:"***
1. **_outputResumes directory**: This directory is where CreateResumes.sh deposits any PDFs it generated for the Resume. See "CreateResumes.sh" notes below for more on how this directory is used. </br>
**.gitignore**: All of the different resumes' should have their "_outputResume" directories ignored by git as their contents are not relevant to the function of the program. For a completed example resume see "FILL-IN-LATER" in "_sampleData" directory.
1. **_sass directory**: This directory allows for the resume to have its own ***Alternative Resume Style*** in addition to/modifying, or completely replacing, the default style (i.e. "_sass/defaultStyle.scss"). These additional .scss files are included in the order they appear in the "style_list:" config option in the root _config **NOTE**: "defaultStyle.scss" is ALWAYS loaded first, meaning that all .scss files in the resume _sass directory will come after (in the oder they appear in the "style_list:" config option), and thus can override, the default styles. </br> 
The .scss files placed in this directory can have any name, but my convention is NOT to use the resume's name (as that could get quite long). How this file is actually added to the resume is fully covered in Step 2 of _config.yml setup. </br> 
These .scss files need no specific example. Internally they are standard .scss files. 
1. **index.md**: This is the 'Resume Page' itself. **HOWEVER**, the main use of this page is that in its Jekyll Front Matter (i.e. between the two sets of three dashes) is where you can enter any of the Content Switches to modify the output Resume. Note: this is an .md file as they do not require 'no-formatting saves' to keep YAML switches with right indentation. </br>
This **MUST** be included and only needs to contain Jekyll Front matter and the Jekyll/Liquid 'include defaultContent' block. </br>
**SEE** "_sampleIndexTemplate.md" in "_sampleData" directory for example of this.

**Required Naming Conventions**: All Resume directory files, be they Data or Template files, etc. **MUST ADHERE** to the directory/file naming conventions for CreateResumes.sh to work. The **EXCEPTION** to this is the .scss files under the resume's _sass directory, these can have any name desired. </br>
Within a Resume directory all directories and files are named as if they existed in root directory, i.e. _data, _sass and _includes and not _testData, _xJobData etc. Note that all of these names are 'fake' in the sense that Jekyll doesn't see them as different from any other directory, hence _data is really a 'config directory' and cannot be used at all like the regular _data directory. </br>
File names also should match root directory names, i.e. contactInfoData.yml and not testContactInfoData.yml. This way default templates, data files, etc. share the same name and do not require CreateResumes.sh to try to adjust the names around to get the right files.

### Config File Setup for the new Resume:
In the _config.yml file the following settings **MUST** be adjusted *each time you want to generate a different resume*: 
* ***Select Target Directory***: You must first select which resume you want to generate by targeting its directory.In _config.yml, in the TARGET section change second item under "include" (marked with the same line comment "#Target") to the resume directory you want to generate page from i.e. _baseResume or _shortResume. </br>
Note this system is set up such that the project 'root' is technically where Jekyll is generating the 'website' from, but as there is no index.md file in root it looks in the directories 'included' by the root config file, i.e. the "target directory".

If all settings are set to their "default" values (commented next to the option as "#default:") a standard base resume will be generated. However, the following aspects of the generation can be changed from the default:
* **Resume Contents**: The config setting "defaultResumeContents:" is the list of Element Templates used by defaultContents.html to generate the Resume. This is usually STATIC but this option allows for switching to a different Resume organization without deleting the previous one.
***NOTE: This list is the ORDER THE elements will appear in on the Resume. Element order can ONLY be changed from here!***
* ***Alternative Resume Style***: If the resume is to be generated with any other style than the default (either additional styles or a completely new style) you **MUST** complete the following steps: 
  1. ***Add the Resume's Style Directory***: First, in the CHANGE STYLE section you must add the load path of your additional/replacement scss file to the list in the first option, "load_paths," under the "sass" option. This load path is the file(s) under the _sass directory of the target resume directory, for example additionalStyle.scss under the _testResume directory is added as so: [_resumes/_testResume/_sass]. </br>
  NOTE: the "load_paths" option only allows for the loading of scss 'partials' from other places than the "_sass" directory in root. It does not add them the generation. That is done in the next sub-step.
  2. ***Add the Additional Stylesheets***: Second, any additional/alternative stylesheets for this resume **MUST** have their names included under the "style-list:" config variable. This name is simple the name of each file without extension. ***NOTE***: The order these files are listed is the order they will be 'included' and thus the order in which their styles will override each other. ***So care needs to be taken to make sure they are in the right order.*** </br>
   Next: If you wish to use additional stylesheets alongside the default stylesheet set the "additional_styles:" option to "true." Alternatively, if you whish to replace the default stylesheet and use only one(s) specific to that resume you must set the "replace_default_style:" option to "true."

**Static Options**: Some options, in the config or certain files, such as "defaultLayout.html" or "assets/css/styles.scss" are noted as STATIC or as 'generally STATIC'. These are options meant to be more or less permanently left alone, e.g. like the default layout, which contains no page data. It is just the head info and such needed for a 'website'. All actual page content comes from index.md so no other/child layouts should be needed. 

**Secret Data File**: Some Data files, namely "contactInfoData" has a portion of its data that should be kept "secret", such as phone numbers, email addresses, and locations. These Data files have a corresponding entry in the Data File "_data/secretData.yml" that holds this secret data. This secret Data file is setup like any other YAML Data file in this project, with the "file name" being use as the top level key (though in this case with "SecretData" replacing "Data" in the file name, e.g. contactInfoSecretData). In the future, each Data file with secret data will have its own key in "_data/secretData.yml" so that all secret data can be contained in this single file. The secret Data file is kept "secret" by being included in the git-ignore file so it is **ONLY** local. </br>
The single Template file that access the secret Data file is hard-coded to access "" within "_data/secretData.yml" and this cannot be changed be either front matter or config variables. </br>
**SEE** "_sampleSecretData.yml" in "_sampleData" directory for example of this.


## Generating a Resume

### CreateResumes.sh:
***Once the above setup is complete***, the program CreateResumes.sh can be used to automatically generate a 'website' for viewing and tweaking the resume, or print the resume to a PDF. </br>
This program main propose is to detect the resume's _config.yml file and any 'modified' data and templates files in the resume's directory and add them where appropriate to generate the final resume. This is done via CreateResumes first adding any modified "data" files as additional config files alongside the resume's own config file (as this is the only way to have resume specific 'data' files), and then adding the necessary YAML to the resume's own config file to tell the 'defaultContent.html' what templates to use for each Element of the resume (modified or default) and in each template what data file to use to generate its Element.
When run in 'viewing' mode, i.e. without the --print flag, the 'website' is deployed with the Jekyll Serve "--livereload" flag, allowing the modifications to all files aside from configs to be immediately applied to the 'website' when the file is saved. Thus allowing for easier modification of the resume towards its final form.

#### Print-to-PDF with the --print Flag:
When "CreateResumes.sh" is run in 'print' mode, i.e. it is given the [-p, --print] flag, it will run Print-to-PDF once 'website' is setup then automatically shut the 'website' down and end the program. This allows a PDF to be created quickly once the resume is fully setup (i.e. all data, templates, front matter variables, etc. are set to produce the desired Resume).

### Using CreateResumes.sh:
CreateResumes os designed to be run in Project root to function correctly. Files are output from CreateResumes with file names in the following format: "TestResume_24-10-31_14:02:24" into the resume's "_outputResumes" directory; both file names and output location are hard-coded. (Filename generation is hard-coded so that any number can be generated without any having matching filenames and so that they will be organized from oldest to newest).

**Usage**: 
* CreateResumes.sh [-h, --help] [-s DIR, --source DIR] [-p, --print]

**Options**:
* **-h, --help** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Display this help message
* **-s, --source** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Source resume directory, DIR, in project "_resumes" directory, e.g. "_testResume" or "_baseResume"
* **-p, --print** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Print-to-PDF resume, then end program

**Examples**:
* **Generate for Viewing**: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bash CreateResumes.sh -s _testResume
* **Print-to-PDF**: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bash CreateResumes.sh -s _testResume --print
