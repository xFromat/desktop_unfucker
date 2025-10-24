$docs = @{
	Path = "dokumenty"
	Description = "Documents like files grouped together"
	Skip = $false
}
$apps = @{
	Path = "aplikacje"
	Description = "Applications that were on the Desktop"
	Skip = $true
}
$calc = @{
	Path = "excel"
	Description = "Calc sheets"
	Skip = $false
}
$slide = @{
	Path = "powerPoint"
	Description = "Multimedia presentations"
	Skip = $false
}
$install = @{
	Path = "instalki"
	Description = "Install files"
	Skip = $false
}
$mpx = @{
	Path = "audio_video"
	Description = "Audio and video files"
	Skip = $false
}
$pics = @{
	Path = "zdjecia"
	Description = "Pictures files"
	Skip = $false
}
$zips = @{
	Path = "zips"
	Description = "Archives"
	Skip = $false
}
$idk = @{
	Path = "losowe"
	Description = "Target user just does not use this file type probably"
	Skip = $false
}

@{ 
	doc = $docs
	docx = $docs
	odt = $docs
	rtf = $docs
	txt = $docs
	pdf = @{
		Path = "pdf"
		Description = "All pdfs files"
	}
	
	dir = @{
		Path = "foldery"
		Description = "Directories that has been sitting on desktop"
	}

	lnk = $apps
	url = $apps

	mp4 = $mpx
	mkv = $mpx
	avi = $mpx
	mov = $mpx
	wmv = $mpx
	flv = $mpx
	mp3 = $mpx
	wav = $mpx
 	flac = $mpx
	aac = $mpx
	ogg = $mpx
	wma = $mpx
	m4a = $mpx
	opus = $mpx

	jpg = $pics
	jpeg = $pics
	png = $pics
	gif = $pics
	bmp = $pics
	webp = $pics
	tiff = $pics
	ico = $pics
	heic = $pics
	svg = $pics

	msi = $install
	msix = $install
	exe = $install

	xls = $calc
	xlsx = $calc
	ods = $calc
	csv = $calc
	tsv = $calc

	ppt = $slide
	pptx = $slide
	odp = $slide
	key = $slide

	zip= $zips
	rar= $zips
	tar = $zips
	gz = $zips
	"7z" = $zips
	cab = $zips

	cmd = $idk
	bat = $idk
	ps1 = $idk
	vbs = $idk
	iso = $idk
	json = $idk
	yaml = $idk
	yml = $idk
	log = $idk
	xml = $idk
	ini = $idk
	toml = $idk
	md = $idk
	bak = $idk
	bin = $idk
	dat = $idk
	cer = $idk
	crt = $idk
	pem = $idk
	msu = $idk
	reg = $idk
	tmp = $idk
	js = $idk
	py = $idk

	default = $idk
}

