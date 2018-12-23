# Shanghai-Hackthon-Tensor

<img src="https://github.com/COAOX/hackathon-bitrun/blob/master/Tensor/img/logo.jpg" width = "100" height = "100" div align=right />

## 简介

我们的项目是一款基于以太坊的卡牌游戏。用户通过支付一定ETH的方式获得抽卡机会，抽卡会获得不同等级的卡牌。
用户通过抽卡获得的卡片能够被用于收藏、对战以及拍卖。

卡片拥有五种等级S、A、B、C、D，稀有度递减，更高稀有度的卡牌一般拥有更高的属性值，每张卡牌在被抽取的时候生成，属性在被抽取的时候唯一确定，并永远不可更改。


## 游戏特点

1. 与一般的卡牌游戏不同的是，我们的卡牌既不是无法更改与回收的物理纸牌，也不是能够被开发商随意更改的简单的一个数据，每张卡牌本质上是一个ERC721的token
每种卡牌的数量在游戏部署之初被规定好了数量，无法被任何人更改。

2. 卡牌的抽取和拍卖完全的公开和透明，所有用户可以实时验证已存在的抽取和拍卖交易。

3. 在对战机制中，我们设计了随机胜利的方式，更强的实力意味着更大的胜利概率，这维持了游戏的平衡性。

4. 与传统卡牌不同的是，你可以一键拍卖自己的卡牌并获得收益。与此同时，你也能够通过拍卖的方式获得梦寐以求却始终没有抽到的稀有卡片。

![card](https://github.com/COAOX/hackathon-bitrun/blob/master/Tensor/img/readme.jpg "区块链")

## Try it

```
npm install lite-server
npm run dev
```

