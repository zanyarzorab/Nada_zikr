# imanikurd-hadith

Kurdish Hadith collection and search logic. Part of the `imanikurd` toolkit.

## Installation

```bash
npm install imanikurd-hadith
```

## Features

- **Hadith Database**: Kurdish translations of key Hadiths.
- **Search capabilities**: Search Hadith texts by keyword.

## Usage

```typescript
import { getHadith, searchHadiths } from "imanikurd-hadith";

// Get Hadith #1
const hadith = getHadith(1);
console.log(hadith.text); // Hadith content in Kurdish

// Search Hadiths
const results = searchHadiths("نوێژ");
console.log(results.length);
```
