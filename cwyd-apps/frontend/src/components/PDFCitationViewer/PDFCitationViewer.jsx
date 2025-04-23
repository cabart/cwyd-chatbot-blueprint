import React, { useCallback, useState } from 'react';
import { Document, Page, pdfjs } from 'react-pdf';
import "react-pdf/dist/esm/Page/TextLayer.css";

pdfjs.GlobalWorkerOptions.workerSrc = new URL('pdfjs-dist/build/pdf.worker.min.js', import.meta.url).toString();

/** Show a pdf at a given page number and highlight the provided text. */
export const PDFCitationViewer = (props) => {

  const [searchText, setSearchText] = useState(props.searchText);
  const [numPages, setNumPages] = useState(null);
  const [pageNumber, setPageNumber] = useState(props.pageNumber);

  function onDocumentLoadSuccess({ numPages }) {
    setSearchText(props.searchText);
    setNumPages(numPages);
    setPageNumber(props.pageNumber);
  }

  /** Handle text highlighting
  Mark words of length > 3 of individual `item` that are contained in `searchText`. */
  const textRenderer = useCallback((item) => {
    var new_text = item.str;
    item.str.split(" ").forEach((word) => {
      if (searchText.includes(word)) {
        if (word.length > 3) {
          new_text = new_text.replace(word, value => `<mark>${value}</mark>`);
        }
      }
    });
    return new_text;
  }, [searchText]);

  /** Handle page switching */
  function changePage(offset) {
    setPageNumber(prevPageNumber => prevPageNumber + offset);
  }

  function previousPage() {
    changePage(-1);
  }

  function nextPage() {
    changePage(1);
  }

  return (
    <>
      <Document file={props.pdfURL} renderMode="canvas" onLoadSuccess={onDocumentLoadSuccess}>
        <Page
          pageNumber={pageNumber}
          customTextRenderer={textRenderer}
          renderAnnotationLayer={false}
        />
      </Document>
      <div class="center">
        <>
          <button type="button" disabled={pageNumber <= 1} onClick={previousPage}>
            {"<"}
          </button>
          &nbsp; {pageNumber || (numPages ? 1 : '--')} / {numPages || '--'} &nbsp;
          <button
            type="button"
            disabled={pageNumber >= numPages}
            onClick={nextPage}
          >
            {">"}
          </button>
        </>
      </div>
    </>
  );
}