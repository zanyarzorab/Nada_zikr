# **What is the package?**
A package to get Islamic things and azkar and supplications easily
<br>
In some azkar and supplications, if he finds an explanation, he will tell you his explanation in two languages: Arabic, English.

# **Installation**
```js
npm install azkars
yarn add azkars
pnpm add azkars
```

# **Using Azkars**

```js
const { Azkar } = require("azkars");
const { EmbedBuilder } = require("discord.js");

 const Embed = new EmbedBuilder()
        .setTitle(`Azkar`)
        .setDescription(`Arabic: ${Azkar.Arabic()} \nEnglish: ${Azkar.English()}`)
        .setColor("Blue");

    return interaction.reply({ embeds: [Embed], ephemeral: true });   
```

# **Using Prophet Names**
```js
const { Prophet } = require("azkars");
const { EmbedBuilder } = require("discord.js");

const Embed = new EmbedBuilder()
        .setTitle(`Prophet Names`)
        .setDescription(`Arabic: ${Prophet.Arabic()} \nEnglish: ${Prophet.English()}`)
        .setColor("Blue");

    return interaction.reply({ embeds: [Embed], ephemeral: true });
```
<br>
