#!/bin/bash
cd /app/documentation/ || exit 1

INSIDE_FILENAME="$(basename "$FILE_LOCATION")"

# Generate a temporary random file name
FILENAME=$(mktemp).pdf

# Get all directories
alldirs=$(find . -type d | paste -sd:) || exit 1

# Get all the markdowns in order
tmp=$(grep -oP '(?<=]\().*(?=\))' _sidebar.md | tr '\r\n' ' ') || exit 1

# Generate the PDF with pandoc
pandoc $tmp -o "$FILENAME" "-fmarkdown-implicit_figures -o" \
  --from=markdown -V geometry:margin=.6in \
  --toc -V toc-title:"Table des matières" \
  --resource-path $alldirs --variable urlcolor=cyan \
  --wrap=preserve -V documentclass=report \
  -V 'mainfont:Roboto-Regular' -V 'mainfontoptions:BoldFont=Roboto-Bold, ItalicFont=Roboto-Italic, BoldItalicFont=Roboto-BoldItalic' \
  --pdf-engine=xelatex || exit 1

# Add a cover to the PDF (ghostscript)
gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="/tmp/$INSIDE_FILENAME" "/resources/cover.pdf" "$FILENAME" || exit 1

# Fix permissions
chmod ugo+rwx "/tmp/$INSIDE_FILENAME" || exit 1
chown $CHOWN_IDU:$CHOWN_IDG "/tmp/$INSIDE_FILENAME" || exit 1

rm "$FILENAME" || exit 1

GREEN='\033[0;32m'
RESET='\033[0m'
echo -e "${GREEN}PDF generated successfully!${RESET}"
