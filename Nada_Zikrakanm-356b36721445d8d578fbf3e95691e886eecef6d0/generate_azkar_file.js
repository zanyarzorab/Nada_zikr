const data = require('./node_modules/imanikurd/data/dhikr.json');
const fs = require('fs');

const afterSleep = data.items.filter(d => d.categoryId === 1);
const afterPrayer = data.items.filter(d => d.categoryId === 9);

let content = '===============================================\n';
content += 'AFTER SLEEP AZKAR (ویردەکانی لە خەو ھەستان)\n';
content += '===============================================\n\n';

afterSleep.forEach((item, index) => {
  content += `Item ${index + 1} (ID: ${item.id})\n`;
  content += `Repeat: ${item.count} time(s)\n`;
  content += `\nArabic:\n${item.arabic}\n`;
  content += `\nKurdish:\n${item.kurdish}\n`;
  content += `\n${'─'.repeat(60)}\n\n`;
});

content += '\n\n===============================================\n';
content += 'AFTER PRAYER AZKAR (زیکری دوای دەست نوێژ)\n';
content += '===============================================\n\n';

afterPrayer.forEach((item, index) => {
  content += `Item ${index + 1} (ID: ${item.id})\n`;
  content += `Repeat: ${item.count} time(s)\n`;
  content += `\nArabic:\n${item.arabic}\n`;
  content += `\nKurdish:\n${item.kurdish}\n`;
  content += `\n${'─'.repeat(60)}\n\n`;
});

fs.writeFileSync('./after_sleep_prayer_azkar.txt', content, 'utf8');
console.log('✓ File created: after_sleep_prayer_azkar.txt');
console.log(`\nAfter Sleep: ${afterSleep.length} items`);
console.log(`After Prayer: ${afterPrayer.length} items`);
