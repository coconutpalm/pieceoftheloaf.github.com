package hymnal

import scalamake.SPrintf._

object Book {
  /**
   * Get the book template for a particular type of book.  Choices are:
   * "chorded", "lyric", or "slides"
   * 
   * Note we have to double up backslashes before u's to avoid unicode escapes
   */
  def start(bookType : String) = 
"""\documentclass[letterpaper,twoside]{article}
\pagestyle{headings}"""+
"\n\\usepackage[%s]{songs}\n"+
"\\usepackage[dvips]{graphicx}"+
"""

\setlength{\oddsidemargin}{0in}
\setlength{\evensidemargin}{0in}
\setlength{\textwidth}{6.5in}
\setlength{\topmargin}{0in}
\setlength{\topskip}{0in}
\setlength{\headheight}{0in}
\setlength{\headsep}{0.25in}
\setlength{\textheight}{9.1in}

\newindex{titleidx}{titleidx}
\newscripindex{scripindex}{scripindex}
\noversenumbers

\begin{document}
""" << bookType
  
  def end = """

\onesongcolumn
\pagestyle{plain}
\showindex{Index by Title and First Line}{titleidx}
\showindex{Index of Scripture References}{scripindex}

\end{document}
"""
  
  def startSongSection(name : String, startNumber : String) = """
\songsection{%s}

\begin{songs}{titleidx,scripindex}
\setcounter{songnum}{%s}
""" << (name, startNumber)
  
  def endSongSection = """
\end{songs}
"""

  def newPage = """
\clearpage
\newpage
"""
  
  def oneSongColumn = """
\onesongcolumn
"""

  def twoSongColumns = """
\twosongcolumns
"""
  
  // cr = Copyright notice
  // sr = Scripture reference(s)
  // index = Text of first line for index
  def song(metadata: String, songBody : String) = """
\beginsong%s
%s
\endsong
""" << (metadata, songBody)

  def score(s : String) = 
    "\\includegraphics[scale=0.90]{%s}" << s
//    "\\includegraphics[scale=0.65]{%s}" << s
  
}
