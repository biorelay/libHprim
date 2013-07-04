parser grammar HprimsParser;

options {

    // Default language but name it anyway
    //
    language  = Java;

    // Use the vocabulary generated by the accompanying
    // lexer. Maven knows how to work out the relationship
    // between the lexer and parser and will build the 
    // lexer before the parser. It will also rebuild the
    // parser if the lexer changes.
    //
    tokenVocab = HprimsLexer;
    
    superClass = AbstractHprimsParser;
    
}

@header {
import com.github.aiderpmsi.libhprim.parser.AbstractHprimsParser;
import java.util.HashMap;
}

hprim
@init{startDocument();}
@after{endDocument();} :
  line_h
  CR* CRNONPRINTABLE* EOF;

// line h (same for all versions)
line_h:
   a=HCONTENT {startElement("H.1");content($a.text);endElement();}
   b=HDELIMITER1 c=HDELIMITER2 d=HREPETITER e=HESC f=HDELIMITER3 {startElement("H.2");content($b.text + $c.text + $d.text + $e.text + $f.text);endElement();}
   DELIMITER1 g=content {matchRegex($g.contentText, "^.{0,12}$");} {startElement("H.3");content($g.contentText);endElement();}
   DELIMITER1 h=content {matchRegex($h.contentText, "^.{0,12}$");} {startElement("H.4");content($h.contentText);endElement();}
   DELIMITER1 i=content {matchRegex($i.contentText, "^.{0,12}$");} {startElement("H.5");content($i.contentText);endElement();}
   DELIMITER1 j=content {matchRegex($j.contentText, "^.{0,12}$");} {startElement("H.6");content($j.contentText);endElement();}
   DELIMITER1 k=content {matchRegex($k.contentText, "^.{0,12}$");} {startElement("H.7");content($k.contentText);endElement();}
   {tryRegex($k.contentText, "^(?:ADM)|(?:ORU)$")}?
   DELIMITER1 l=content {matchRegex($l.contentText, "^.{0,12}$");} {startElement("H.8");content($l.contentText);endElement();}
   DELIMITER1 m=content {matchRegex($m.contentText, "^.{0,12}$");} {startElement("H.9");content($m.contentText);endElement();}
   DELIMITER1 n=content {matchRegex($n.contentText, "^.{0,12}$");} {startElement("H.10");content($n.contentText);endElement();}
   DELIMITER1 o=content {matchRegex($o.contentText, "^.{0,12}$");} {startElement("H.11");content($o.contentText);endElement();}
   DELIMITER1 p=content {matchRegex($p.contentText, "^.{0,12}$");} {startElement("H.12");content($p.contentText);endElement();}
   DELIMITER1 q=content {matchRegex($q.contentText, "^.{0,12}$");} {startElement("H.13");content($q.contentText);endElement();}
   {tryRegex($q.contentText, "^H2\\.[0-2]$")}?
   CR+ CRNONPRINTABLE*
   ( {$k.contentText.equals("ADM")}?
       ({$q.contentText.equals("H2.0")}? body_adm_2_0
        |
        {$q.contentText.equals("H2.1")}? body_adm_2_1
        |
        {$q.contentText.equals("H2.2")}? body_adm_2_2)
   | {$k.contentText.equals("ORU")}?
       ({$q.contentText.equals("H2.0")}? body_oru_2_0
        |
        {$q.contentText.equals("H2.1")}? body_oru_2_1
        |
        {$q.contentText.equals("H2.2")}? body_oru_2_2)
   );

// Line P (patient)
line_p:
  LINE_P CRDELIMITER1 content;

// Line OBR (Result)
line_obr:
  LINE_OBR CRDELIMITER1 content;


// Types de corps
body_adm_2_0:
  ;

body_adm_2_1:
  ;

body_adm_2_2:
  ;

body_oru_2_0:
  ;

body_oru_2_1:
  line_obr*;

body_oru_2_2:
  ;

// Répétitions de champs entre délimiteurs 2
lvl1_fields[String nameElement, List<String> patterns, int nbMandatory, String completeFieldPattern]
@init{startElement(nameElement);}
@after{endElement();} :
  r=lvl1_subfields[$nameElement, $patterns, $nbMandatory, 1, new StringBuilder(), $completeFieldPattern];
  
lvl1_subfields[String nameElement, List<String> patterns, int nbMandatory, int size, StringBuilder recorded, String completeFieldPattern]:
  {$size == $patterns.size()}?
    {startElement($nameElement + "." + $size);}
    g=content
    {matchRegex($g.contentText, $patterns.get($size - 1));
     content($g.contentText);
     endElement();
     $recorded.append($g.contentText);}
    ({getStrictNess() <= MEDIUM_CONFORMANCE}?
     DELIMITER2 h=content? {matchRegex($h.contentText, "^\$");})
    {matchRegex($recorded.toString(), $completeFieldPattern);}
  |
  {$size < $nbMandatory}?
    {startElement($nameElement + "." + $size);}
     g=content
    {matchRegex($g.contentText, $patterns.get($size - 1));
     content($g.contentText);
     endElement();
     $recorded.append($g.contentText);}
    DELIMITER2 lvl1_subfields[$nameElement, $patterns, $nbMandatory, $size + 1, $recorded, $completeFieldPattern]
  |
  {startElement($nameElement + "." + $size);}
  g=content
  {matchRegex($g.contentText, $patterns.get($size - 1));
  $recorded.append($g.contentText);
  endElement();}
  (DELIMITER2
   lvl1_subfields[$nameElement, $patterns, $nbMandatory, $size + 1, $recorded, $completeFieldPattern]
   |
   {matchRegex($recorded.toString(), $completeFieldPattern);})
  ;

// Types de base pour les contenus
content returns [String contentText]:
  g=baseContent {$contentText = ($g.text == null ? "" : $g.text);}
  (CR+ CRNONPRINTABLE* LINE_A CRDELIMITER1 h=content {$contentText = $contentText + ($h.contentText == null ? "" : $h.contentText);})?;

// Contenu de base
baseContent :
  CONTENT?;