import info.bliki.wiki.dump.{Siteinfo, WikiArticle, IArticleFilter}
import info.bliki.wiki.model.WikiModel
import java.io.{PrintWriter, File}
import org.jsoup.Jsoup
import org.jsoup.nodes.Document
import org.jsoup.select.Elements
import scala.util.matching.Regex
import scala.collection.JavaConversions._

class ArticleFilter(outFile : File) extends IArticleFilter{
  val outRawDir = new File(outFile, "raw")
  var count = 0
  val headerDelimiter = "|"
  val wikiModel = new WikiModel("", "")

  val contentTags = List("h1", "h2", "h3", "h4", "h5", "h6", "p")

  val sectionRegex = new Regex("""={1,6}(.*?)={1,6}""", "heading")
  val indentRegex = new Regex("""(^|\n)(\:{1,6})""", "newline", "indent")
  val tagRegex = new Regex("""<.*?/?>""")
  val imageRegex = new Regex("""\[\[File\:.*?\]\]""")
  val itbRegex = new Regex("""'{2,5}""")
  val interwikiLink = new Regex("""\[\[(.*?:)?(.*?)\|\]\]""", "prefix", "name")
  val linkRegex = new Regex("""\[\[(.*?[\|:])?(.*?)\]\]""", "link", "name")

  if (!outRawDir.exists()) {
    outRawDir.mkdirs()
  }

  def wikiToPlain(text: String) : String = {
    var newText = text.replaceAll("(?m)<ref>.+</ref>", " ")
            .replaceAll("(?m)<ref name=\"[A-Za-z0-9\\s-]+\">.+</ref>", " ")
            .replaceAll("<ref>", " <ref>")
    // section markers
    newText = sectionRegex.replaceAllIn(text, m => headerDelimiter + m.group("heading") + headerDelimiter + "\n")
    // indented text
    newText = indentRegex.replaceAllIn(newText, m => m.group("newline"))
    // html style tags
    newText = tagRegex.replaceAllIn(newText, "")
    // italics and bold
    newText = itbRegex.replaceAllIn(newText, "")
    // images
    newText = imageRegex.replaceAllIn(newText, "")
    // links
    // category links?
    newText = interwikiLink.replaceAllIn(newText, m => m.group("name"))
    newText = linkRegex.replaceAllIn(newText, m => m.group("name"))

    newText
  }

  def process(page: WikiArticle, siteInfo: Siteinfo) {
    if (count >= 10) {
      sys.exit(0)
    }

    if (page != null && page.getText != null && !page.getText.startsWith("#REDIRECT ")) {
      val writer = new PrintWriter(new File(outFile, page.getId), "UTF-8")
      val rawWriter = new PrintWriter(new File(outRawDir, page.getId + ".raw"), "UTF-8")

      val html = wikiModel.render(page.getText)
      val doc:Document = Jsoup.parse(html)
      val elts:Elements = doc.getAllElements

      for (elt <- elts) yield {
        if (contentTags.contains(elt.tagName())) {
          if (elt.text().trim != "Contents") {
            var content: String = elt.text()

            if (content.trim != "") {
              rawWriter.write(content.trim() + "\n\n")

              content = content.replaceAll("""\s*\{\{byline\}\}\s*""", "\n\n")
              content = content.replaceAll("""\s*\{\{[A-ZÆØÅa-zæøå0-9+s\-\_\s]+?\}\}\s*""", " ")
              writer.write(content.trim + "\n\n")
            }
          }
        }
      }

      writer.close()
      rawWriter.close()

      count += 1
    }
  }
}
