interface AdaptiveCardTextBlock {
  type: string;
  text: string;
  weight?: "bolder";
  size?: "large" | "medium" | "default" | "small";
  isSubtle?: boolean;
  wrap?: boolean;
}

// Convert markdown line to adaptive card text blocks (does not convert table lines)
function processMarkdownLineNotTable(line: string): AdaptiveCardTextBlock | null {
  line = line.trim();

  // Handle headers (e.g., #, ##, ###)
  if (line.startsWith('### ')) {
    return {
      type: "TextBlock",
      text: line.replace(/^### /, ''),
      size: "medium",
      weight: "bolder",
      wrap: true
    };
  } else if (line.startsWith('## ')) {
    return {
      type: "TextBlock",
      text: line.replace(/^## /, ''),
      size: "medium",
      wrap: true
    };
  } else if (line.startsWith('# ')) {
    return {
      type: "TextBlock",
      text: line.replace(/^# /, ''),
      size: "large",
      weight: "bolder",
      wrap: true
    };
  }

  // Handle bold (**text**)
  if (/\*\*(.*?)\*\*/.test(line)) {
    const boldText = line.replace(/\*\*(.*?)\*\*/, '**$1**');
    return {
      type: "TextBlock",
      text: boldText.replace(/\*\*/g, ''),
      weight: "bolder",
      wrap: true
    };
  }

  // Handle italic (*text*)
  if (/\*(.*?)\*/.test(line)) {
    const italicText = line.replace(/\*(.*?)\*/, '*$1*');
    return {
      type: "TextBlock",
      text: italicText.replace(/\*/g, ''),
      isSubtle: true,
      wrap: true
    };
  }

  // Handle unordered lists (- item) with indentation for nested items
  const match = line.match(/^(\s*)- (.*)$/);
  if (match) {
    const indentLevel = match[1].length / 2; // 2 spaces per indent level
    const text = match[2];

    // Add bullet points with appropriate indentation
    return {
      type: "TextBlock",
      text: `${'  '.repeat(indentLevel)}• ${text}`,
      wrap: true
    };
  }

  // Plain text
  return {
    type: "TextBlock",
    text: line,
    wrap: true
  };
}

interface Table {
  heading: string[];
  body: string[][];
}

export function renderTable(table: Table): object {
  const columnWidths: number[] = [];
  const rows: object[] = [];

  // Calculate column widths based on headers and body
  table.heading.forEach((header, index) => {
    columnWidths[index] = header.length;
  });

  table.body.forEach(row => {
    row.forEach((cell, index) => {
      columnWidths[index] = Math.max(columnWidths[index], cell.trim().length);
    });
  });

  // Render headers
  const headerRow = table.heading.map((header, index) => ({
    type: "TableCell",
    items: [{
      type: "TextBlock",
      text: header,
      horizontalAlignment: "Left",
      wrap: true,
      size: "Medium",
      weight: "Bolder"
    }]
  }));
  rows.push({
    type: "TableRow",
    cells: headerRow,
  });

  // Render body rows
  if (table.body.length === 0) {
    const emptyDataRow = {
      type: "TableCell",
      items: [{
        type: "TextBlock",
        text: "No data available"
      }]
    };
    rows.push({
      type: "TableRow",
      cells: [emptyDataRow],
    });
  } else {
    table.body.forEach(row => {
      const dataRow = row.map((cell, index) => ({
        type: "TableCell",
        items: [{
          type: "TextBlock",
          text: cell,
          horizontalAlignment: "Left",
          wrap: true
        }]
      }));
      rows.push({
        type: "TableRow",
        cells: dataRow,
      });
    });
  }

  // Generate the Adaptive Card table

  return {
    type: "Table",
    columns: table.heading.map((header, index) => ({
      type: "Column",
      width: columnWidths[index],
    })),
    rows: rows,
  }
}


export function renderTableAscii(table: Table): string {
  const columnWidths: number[] = [];
  const lines: string[] = [];

  // Calculate column widths based on headers and body
  table.heading.forEach((header, index) => {
    columnWidths[index] = header.length;
  });

  table.body.forEach(row => {
    row.forEach((cell, index) => {
      columnWidths[index] = Math.max(columnWidths[index], cell.trim().length);
    });
  });

  // Render headers
  lines.push(renderRow(table.heading, columnWidths));
  lines.push(renderSeparator(columnWidths));

  // Render body rows
  if (table.body.length === 0) {
    lines.push(renderEmptyDataRow(columnWidths.length));
  } else {
    table.body.forEach(row => {
      lines.push(renderRow(row, columnWidths));
    });
  }

  // Join all lines with newline characters
  return lines.join('\n');
}

export function renderRow(row: string[], columnWidths: number[]): string {
  let rowLine = '|';
  row.forEach((cell, index) => {
    const width = columnWidths[index];
    const paddedCell = ' ' + cell.trim().padEnd(width) + ' ';
    rowLine += paddedCell + '|';
  });
  return rowLine;
}

export function renderSeparator(columnWidths: number[]): string {
  let separatorLine = '+';
  columnWidths.forEach(width => {
    separatorLine += '-'.repeat(width + 2) + '+';
  });
  return separatorLine;
}

export function renderEmptyDataRow(numColumns: number): string {
  let emptyRowLine = '|';
  emptyRowLine += ' No data found '.padEnd(numColumns * 4 - 1, ' ');
  emptyRowLine += '|';
  return emptyRowLine;
}

export function markdownToAdaptiveCards(markdownText: string): (string | object)[] {
  const lines = markdownText.split('\n');
  let result: (string | object)[] = [];
  let currentTable: Table | null = null;
  let isInsideTable = false;

  for (let line of lines) {
    if (line.trim().startsWith('|') && line.includes('|')) {
      // Line is likely a table row
      const cells = line.split('|').map(cell => cell.trim());
      cells.shift(); // Remove first empty element before the first |
      cells.pop(); // Remove last element after the last |

      // Check if the line is a separator line (only dashes or pipes)
      const isSeparator = cells.every(cell => cell === '');

      if (!currentTable) {
        // Start of a new table
        currentTable = { heading: [], body: [] };
        isInsideTable = true;
      }

      if (!isSeparator) {
        if (currentTable.heading.length === 0) {
          // Assuming it's the header row
          currentTable.heading = cells;
        } else {
          // It's a body row
          currentTable.body.push(cells);
        }
      }
    } else {
      // Not a table row
      if (isInsideTable && currentTable) {
        // End of the current table
        result.push(renderTable(currentTable));
        currentTable = null;
        isInsideTable = false;
      }

      if (line.trim() !== '') {
        result.push(processMarkdownLineNotTable(line.trim()));
      }
    }
  }

  // If there's an unfinished table at the end
  if (currentTable) {
    result.push(renderTable(currentTable));
  }

  return result;
}
