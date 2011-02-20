package hymnal

import scalamake.ScalaMakefile
import scalamake.PlatformExec._
import scalamake.ScalaMake._
import scalamake.scalaMake
import scalamake.SPrintf._
import java.io.File
import java.io.FileOutputStream
import java.io.PrintStream
import scala.io.Source

object HymnalMakefile extends ScalaMakefile {

  // File name bases for the kinds of PDFs we'll build
  val SCORE = "scores"
  val CHORDED = "chords"
  val LYRIC = "lyrics"
  val SLIDES = "slides"

  // Source/Build/output folder names
  val SOURCEDIR = "hymnal-src"
  val SONG_DIR = "%s/songs" << SOURCEDIR
  //val HYMNAL_CONTENTS = "%s/contents-full.txt" << SOURCEDIR
  val HYMNAL_CONTENTS = "%s/contents.txt" << SOURCEDIR
  val BUILD_DIR = "build"
  val OUTPUT_DIR = "output"
  
  // Functions to convert a base file name to full file name or song title
  class FileNameConversions(file : String) {
    def TEX = "%s/%s.tex" << (BUILD_DIR, file)
    def PDF = "%s/%s.pdf" << (OUTPUT_DIR, file)
    def scripture = "%s/scripture/%s.txt" << (SOURCEDIR, file)
    def metadata = "%s/%s/metadata.tex" << (SONG_DIR, file)
    def lyrics = "%s/%s/lyrics.converted" << (SONG_DIR, file) // FIXME!
    def png = "%s/%s/score.png" << (SONG_DIR, file)
    def epsi = "%s/%s/score.epsi" << (SONG_DIR, file)
    def title = file.map(c => if (c == '_') ' ' else c ).mkString
    def asFilename = file.map(c => if (c == ' ') '_' else c).mkString
  }
  implicit def string2FileNameConversions(s : String) = new FileNameConversions(s)
	  
  // Song file targets
  val SONG_FILES = "%s/**" << SONG_DIR
  val LYRIC_FILES = "%s/lyrics.converted" << SONG_FILES
  val ABC_FILES = "%s/*.abc" << SONG_FILES

  // Various paths
  val WEBDIR = "web"
  val WEBSITE = "%s/index.html" << WEBDIR

  // The canon order file (for the scripture index)
  val CANON = "/usr/local/share/songs/bible.can"

  
  // Main targets -----------------------------------------------------------
  
  "ALL" dependsOn ("clean", SONG_FILES, CHORDED.PDF, SCORE.PDF, LYRIC.PDF, SLIDES.PDF, WEBSITE)

  "clean" buildWith {
    SCORE.PDF.delete()
    CHORDED.PDF.delete()
    LYRIC.PDF.delete()
    SLIDES.PDF.delete()
    !("rm -fr %s" << WEBDIR)
    println("Cleaned")
  }
  
  // Utility methods called from subtargets ---------------------------------
  
  def exists(name : String) = new java.io.File(name).exists

  def buildTexBook(bookType : String, includeScores : Boolean) = {
    /*
     * The contents.txt file format is too simple to justify a full-blown 
     * parser.  For reference, here is the grammar (in a loose BNF syntax):
     * 
     * contentsFile :- (songHeaderLine (songLine | scriptureLine | commentLine)*)+
     * 
     * songHeaderLine :- "===" title "===" " " startSongNumber \n
     * 
     * songLine :- [A-Za-Z_]* \n
     * 
     * scriptureLine :- "Scrip: " [A-Za-Z\.]*\n
     * 
     * commentLine :- "#" .*
     * 
     * title :- [A-Za-z &]+
     * 
     * startSongNumber :- [0-9]+
     */
    println("\n*** Building %s book %s music scores..." substituting
              (bookType.TEX, if (includeScores) "including" else "not including"))

    val bookContents : Iterator[String] = Source.fromFile(HYMNAL_CONTENTS).getLines
    
    // Process first line
    val latexFile = new PrintStream(new FileOutputStream(bookType.TEX))
    latexFile.print(Book.start(bookType))
    printSongSectionHeader(latexFile, bookContents.next().trim())

    // Process remainder of lines
    while (bookContents.hasNext) {
      val line = bookContents.next().trim()
      if (!line.startsWith("#") || "" == line) {
	      if (line.startsWith("===")) {
	        latexFile.print(Book.endSongSection)
	        printSongSectionHeader(latexFile, line)
	      } else if (line.toUpperCase.startsWith("SCRIP:")) {
	        if (bookType == "lyric")
	          printScripture(latexFile, line)
	      } else {
	        printSong(latexFile, line.asFilename, includeScores)
	      }
      }
    }

    // End of book...
    latexFile.print(Book.endSongSection)
    latexFile.print(Book.end)
    latexFile.close()
    println("...successfully built " + bookType + " TEX source file")
  }
  
  def printSongSectionHeader(latexFile : PrintStream, line : String) = {
    val lineParts = line.split("===") // returns Array("", "title", " startNum")
    if (lineParts.length != 3) {
      throw new RuntimeException("Expected song section, found: " + line)
    }
    latexFile.print(Book.startSongSection(lineParts(1), lineParts(2).trim))
  }
  
  def printScripture(latexFile : PrintStream, line : String) = {
    val scriptureRef = line.substring(6).trim()
    val fileName = scriptureRef.map(
      char => if (char == ' ' || char == ':') '_' else char ).mkString
    if (!exists(fileName.scripture)) {
      throw new RuntimeException(fileName.scripture + " does not exist")
    }
    val text = Source.fromFile(fileName.scripture).mkString
    latexFile.print(text)
  }

  def printSong(latexFile : PrintStream, song : String, includeScores : Boolean) = {
    val metadata = Source.fromFile(song.metadata).mkString
    val includeScore = includeScores && exists(song.epsi)
    if (includeScore) {
      latexFile.print(Book.oneSongColumn)
    }
    val songContents = 
	    if (includeScore) {
	      Book.score(song.epsi)
	    } else {
	      Source.fromFile(song.lyrics).mkString
	    }
    latexFile.print(Book.song(metadata, songContents))
    if (includeScore) {
      latexFile.print(Book.twoSongColumns)
    }
  }
  
  def buildPDF(file : String, output : String) = {
    println("Building %s PDFs" << file)
    !("latex -output-directory %s %s/%s.tex" << (BUILD_DIR, BUILD_DIR, file))
    !("songidx %s/titleidx.sxd %s/titleidx.sbx" << (BUILD_DIR, BUILD_DIR))
    !("songidx -b %s %s/scripindex.sxd %s/scripindex.sbx" << (CANON, BUILD_DIR, BUILD_DIR))
    !("latex -output-directory %s %s/%s.tex" << (BUILD_DIR, BUILD_DIR, file))

    // Convert dvi to a booklet in postscript format
    !("dvips -o %s/%s.ps %s/%s.dvi" << (BUILD_DIR, file, BUILD_DIR, file))
    !("psbook %s/%s.ps %s/%s.sig.ps" << (BUILD_DIR, file, BUILD_DIR, file)) // rearrange for booklet printing
    !("psnup -l -pletter -2 -s.65 %s/%s.sig.ps %s/%s.2up.ps" << (BUILD_DIR, file, BUILD_DIR, file))
    
    // Convert raw output to pdf files
//    !("dvipdf %s/%s.dvi %s" << (BUILD_DIR, file, output.PDF)) // letter size output
    !("ps2pdf -dEmbedAllFonts=true %s/%s.ps %s/%s.pdf" << (BUILD_DIR, file, OUTPUT_DIR, output))
    !("ps2pdf -dEmbedAllFonts=true %s/%s.2up.ps %s/%s.booklet.pdf" << (BUILD_DIR, file, OUTPUT_DIR, output))
    println("...built %s" << file.PDF)
  }

  // Targets for types of things we build ------------------------------------
  
  SONG_FILES buildWith { dir =>
    "SONG_DIR" buildWith {
      println("\nProcessing song directory: %s" << dir)
      val abcFile = "%s/score.abc" << dir
      val psFile = "%s/score.ps" << dir
      val epsFile = "%s/score.epsi" << dir
      val pngFile = "%s/score.png" << dir
      
      if (exists(abcFile)) { 
        println("==> Found: " + abcFile)

        scalaMake {
          pngFile dependsOn epsFile buildWith {
            !("convert %s %s" << (epsFile, pngFile))
            println("==> (re)built: " + pngFile)
          }
          
          epsFile dependsOn abcFile buildWith {
            !("abcm2ps -O %s %s" << (psFile, abcFile))
            !("ps2epsi %s %s" << (psFile, epsFile))
            println("==> (re)built: " + epsFile)
          }
        }
      }
    }
  }

  SCORE.PDF dependsOn (LYRIC_FILES, ABC_FILES) buildWith {
    buildTexBook("chorded", true)
    buildPDF("chorded", "scores")
  }
  
  CHORDED.PDF dependsOn LYRIC_FILES buildWith {
    buildTexBook("chorded", false)
    buildPDF("chorded", "chorded")
  }
  
  LYRIC.PDF dependsOn LYRIC_FILES buildWith {
    buildTexBook("lyric", false)
    buildPDF("lyric", "lyric")
  }
  
  SLIDES.PDF dependsOn LYRIC_FILES buildWith {
    // TODO: This needs margins fixed and headers deleted
//    buildTexBook("slides", false)
//    buildPDF("slides", "slides")
  }
  
  WEBSITE dependsOn (LYRIC_FILES, ABC_FILES) buildWith {
	  // TODO
	  // foreach song:
	  // Generate a songbook with 1 song
	  // dviselect can extract the page with the song from the dvi file
	  // Then dvips to make it into a ps file
	  // then ps2epsi to make it an eps file
	  // then `convert` the epsi to a png file usable on the web
  }

}
