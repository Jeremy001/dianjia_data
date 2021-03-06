/*
作者：Neo Wang 王政鸣
更新时间：2017-7-4
脚本类型：Impala
 */


-- 商品表
-- 1.JOLLY.WHO_GOODS
SELECT *
FROM JOLLY.WHO_GOODS
LIMIT 10;

-- 关于价格：
-- 1.单位分别是什么？都是人民币？都是美元？
-- 2.MARKET_PRICE和in_PRICE是什么关系？怎么大部分商品这两个价格都相等？
-- 459043件商品中的444613件商品两个价格都相等
/*
IS_ON_SALE
IS_DELETE
IS_STOCK
IS_BEST
IS_NEW
IS_HOT
IS_PROMOTE
IS_PRESALE
IS_CUSTOMIZATION
*/

SELECT COUNT(*)
FROM JOLLY.WHO_GOODS;
-- 46万件商品(459043)

-- IS_ON_SALE 商品销售状态,1销售,0下架,默认1
SELECT IS_ON_SALE
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
GROUP BY IS_ON_SALE;
-- 在售商品近20万件（还不是SKU,而是GOODS_ID）
-- 1   199401
-- 0   259642

-- IS_DELETE 商品删除状态,1删除,0未删除,默认0
SELECT IS_DELETE
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
GROUP BY IS_DELETE;
-- 问题：怎么有的在售商品的删除状态也是已删除呢？

-- IS_BEST 商品精品状态,1精品,0非精品。默认为0
SELECT IS_BEST
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1
GROUP BY IS_BEST;
-- 在售的近20W件商品中，有88件精品
-- 问题：何为精品？
-- 88件精品中86件是新品，莫非精品主要是对新品进行推荐所打的标记？

-- IS_NEW 新品状态,1为新品,0非新品,默认1
SELECT IS_NEW
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1
GROUP BY IS_NEW;
-- 新品近5万个，近20%

-- IS_HOT 热销状态,1为热销,0为非热销,默认0
SELECT IS_HOT
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1
GROUP BY IS_HOT;
-- 不到200个商品，即不到千分之一比例

-- IS_PROMOTE 特价促销状态,1为特价促销,0为非特价促销,默认0
SELECT IS_PROMOTE
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1
GROUP BY IS_PROMOTE;
-- 近7万的商品是促销状态，比例超过三分之一；

-- IS_PRESALE  是否是预售商品(0:非预售;1:预售)
SELECT IS_PRESALE
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1
    AND IS_NEW = 1
GROUP BY IS_PRESALE;
-- 预售商品还是很少的
-- 问题：什么是预售商品？

-- PRICE_TYPE：价格类型,0:商品价格，1:SKU价格

-- ADD_TIME：添加时间
SELECT FROM_UNIXTIME(ADD_TIME, 'yyyy-MM') AS ADD_MONTH
        ,COUNT(GOODS_ID) AS GOODS_NUM
FROM JOLLY.WHO_GOODS
GROUP BY FROM_UNIXTIME(ADD_TIME, 'yyyy-MM')
ORDER BY ADD_MONTH DESC;
-- 2017上半年添加了很多商品呀，特别是4-5-6三个月

-- PROVIDER_CODE
SELECT COUNT(DISTINCT PROVIDER_CODE)
FROM JOLLY.WHO_GOODS;
-- 3117，有点多呀，很多已经不合作了吧？
SELECT COUNT(DISTINCT PROVIDER_CODE)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1;
-- 2014，还是不少。

-- goods_season 产品季节: 1.春 2.夏 3.秋 4.冬 5.春夏 6.春秋 7.春冬 8.夏秋 9.夏冬 10.秋冬
SELECT goods_season
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1
GROUP BY goods_season
ORDER BY goods_season;
-- 问题：0代表秋冬还是10代表秋冬？怎么目前在售的商品中，近一半的goods_season是0呢？
-- 有0也有10，不过10的商品特别少；

-- IS_STOCK 是否卖库存:0 非卖库存 1卖库存 2deals 4 sku卖库存
-- 问题：2DEALS是什么类别？
SELECT IS_STOCK
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1
GROUP BY IS_STOCK;
-- 主要还是非卖库存，20万件商品中近18.5万件是非卖库存的；

-- ITEM_CATEGORY_ID 商品品类ID
-- 关联 JOLLY.WHO_CATEGORY表
SELECT T1.GOODS_ID
        ,T1.GOODS_SN
        ,T1.GOODS_NAME
        ,T1.ITEM_CATEGORY_ID
        ,T2.CN_CAT_NAME
FROM JOLLY.WHO_GOODS T1
LEFT JOIN JOLLY.WHO_CATEGORY T2 ON T1.ITEM_CATEGORY_ID = T2.CAT_ID
LIMIT 10;

-- 看看各个类别层级的商品数
WITH T AS
(SELECT T1.GOODS_ID
        ,T1.GOODS_SN
        ,T1.GOODS_NAME
        ,T1.ITEM_CATEGORY_ID
        ,T2.CN_CAT_NAME
        ,T2.CAT_LEVEL
FROM JOLLY.WHO_GOODS T1
LEFT JOIN JOLLY.WHO_CATEGORY T2 ON T1.ITEM_CATEGORY_ID = T2.CAT_ID
)
SELECT T.CAT_LEVEL
        ,COUNT(T.GOODS_ID)
FROM T
GROUP BY T.CAT_LEVEL
ORDER BY T.CAT_LEVEL;



-- ON_SALE_TIME 上架时间, FIRST_ON_SALE_TIME 第一次上架时间
-- OFF_SALE_TIME 下架时间

-- LEVEL 商品层级，默认0, 1：A,2：B,3：C,4：D
-- 问题：LEVEL是什么含义？怎么分的？
SELECT LEVEL
        ,COUNT(GOODS_ID)
FROM JOLLY.WHO_GOODS
WHERE IS_ON_SALE = 1
GROUP BY LEVEL
ORDER BY LEVEL;
/*
0   59616
1   9236
2   16081
3   55943
4   58525
*/

-- 问题：没在商品信息表中看到性别字段，性别字段存放在哪里？还是说没有这个字段？
-- 答：没有性别字段，很多品类是不分性别的，比如电器，生活用品等

-- 2.ZYDB.DIM_JC_GOODS
-- 前十条记录
SELECT *
FROM ZYDB.DIM_JC_GOODS
LIMIT 10;
-- 一级类目商品数
SELECT CAT_LEVEL1_NAME
        ,COUNT(GOODS_ID) AS GOODS_NUM
FROM ZYDB.DIM_JC_GOODS
GROUP BY CAT_LEVEL1_NAME
ORDER BY GOODS_NUM DESC;
/*
Women's Clothing    189969
Women's Shoes   46247
Women's Accessories 40731
Men's Clothing  31197
Kids    28469
Women's Bags    28167
Baby&Moms   15299
Men's Shoes 15107
Beauty  14428
Home Decor  12568
 */

SELECT CAT_LEVEL
        ,COUNT(*)
FROM ZYDB.DIM_JC_GOODS
WHERE IS_DELETE = 0
GROUP BY CAT_LEVEL
ORDER BY CAT_LEVEL;
-- 都是一二级类目
/*
2   460096
3   2
    38
1   1633
 */

/*
IS_ON_SALE
IS_DELETE
IS_STOCK
IS_NEW
IS_CUSTOMIZATION
*/

-- 测试供应商及商品数
SELECT SUPP_NAME
    ,COUNT(*)
FROM ZYDB.DIM_JC_GOODS
WHERE SUPP_NAME LIKE '测试%'
  OR SUPP_NAME LIKE 'Test%'
GROUP BY SUPP_NAME;
/*
测试供应商3  7
测试供应商1  22
测试供应商2  26
Test    47
 */


-- 商品分类表 JOLLY.WHO_CATEGORY
SELECT *
FROM JOLLY.WHO_CATEGORY
LIMIT 10;

-- IS_SHOW
SELECT IS_SHOW
        ,COUNT(*)
FROM JOLLY.WHO_CATEGORY
GROUP BY IS_SHOW;
/*
1   510
0   134
 */

-- CAT_LEVEL 分类层级
SELECT CAT_LEVEL
        ,COUNT(*)
FROM JOLLY.WHO_CATEGORY
WHERE IS_SHOW = 1
GROUP BY CAT_LEVEL
ORDER BY CAT_LEVEL;
/*
1   33
2   243
3   217
4   17
 */
-- 第一层级有这么多个？

-- 公司目前的所有商品类目
SELECT CAT_ID
        ,PARENT_ID
        ,CN_CAT_NAME
        ,CAT_LEVEL
FROM JOLLY.WHO_CATEGORY
WHERE IS_SHOW = 1;

-- 递归查询，把商品类目层级建立起来；


-- 查询各一级类目的商品数量




-- 查看每天商品的上下架情况
SELECT *
FROM ZYDB.DW_GOODS_ON_SALE
WHERE DATA_DATE = '20170717'
LIMIT 10;


SELECT IS_ON_SALE
    ,COUNT(GOODS_ID)
FROM ZYDB.DW_GOODS_ON_SALE
WHERE DATA_DATE = '20170717'
GROUP BY IS_ON_SALE;


-- 违禁品
/*
key_id = 728          value_id IN (7524, 7526, 7536)
728 Prohibited Goods    7536    Unprohibited    32353
728 Prohibited Goods    7526    Fuzzy Prohibited    5169
728 Prohibited Goods    7524    Completely Prohibited   6162
7524:完全违禁
7526:模糊违禁
7536:不违禁
*/
-- 明细
SELECT goods_id
        ,key_id
        ,'Prohibited' AS key_name
        ,value_id
        ,(CASE WHEN value_id = 7524 THEN '完全违禁'
                     WHEN value_id = 7526 THEN '模糊违禁'
                     WHEN value_id = 7536 THEN '不违禁'
                     ELSE '其他'
          END) AS value_name
FROM jolly.who_pattern_relation
WHERE key_id = 728;



SELECT key_id
    ,key_name
    ,value_id
    ,value_name
    ,COUNT(goods_id)
FROM jolly.who_pattern_relation
WHERE key_id = 728
GROUP BY key_id
    ,key_name
    ,value_id
    ,value_name
;

-- 物流承运商信息表
SELECT *
FROM jolly.who_shipping
;
-- 物流承运商top10
SELECT *
FROM zydb.dw_order_sub_order_fact AS p1
LIMIT 10;




-- 供应商信息表 JOLLY.WHO_ESOLOO_SUPPLIER
SELECT *
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE ADDRESS IS NOT NULL
LIMIT 10;
-- 这些供应商都木有地址！！！？？？

-- GREAT_TIME，也是够了，手又抖了，把CREATE写成了GREAT
-- LAST_TIME, 最后一次登录时间？什么鬼？登录哪里的时间？
-- IS_HIDE，是否取消合作，0否；1是
SELECT IS_HIDE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
GROUP BY IS_HIDE;
/*
1   1846
0   1856
 */
-- PRICE_RATE, 加价系数，什么含义？
-- MONTH_CAPACITY, 月产能，单位是什么？
SELECT CODE
        ,SUPP_NAME
        ,MONTH_CAPACITY
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE MONTH_CAPACITY IS NOT NULL
AND IS_HIDE = 0
ORDER BY MONTH_CAPACITY DESC
LIMIT 30;
-- NEW_CYCLE, 上新周期
-- 文本说明，没有固定时间单位，不便使用
SELECT CODE
        ,SUPP_NAME
        ,NEW_CYCLE
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE NEW_CYCLE IS NOT NULL
AND IS_HIDE = 0
ORDER BY NEW_CYCLE DESC
LIMIT 30;
/*
045 ZY小女王   每隔2天
04D ZY N纳丹堡 每月一次
276 JM G广州羽林箱包  每天上新
1TV ZY A奥比亚皮具   每天
078 ZY H胡伟东 每周四
051 ZY P帕丽达 每周五
278 JM L龙岩市展宇贸易有限公司 每周一次
 */
-- ADMin_ID, 采购员ID
-- CANCEL_REASON, 取消合作原因代码，说明文字放在哪张表中？
-- SUPP_DISCOUNT, 采购折扣(采购价)

-- 采购价，销售价
SELECT p1.sku_id
        ,p2.prop_price AS sell_price_dollar
        ,ROUND(p2.in_price / 6.329, 2) AS purchase_price_dollar
FROM zybiro.neo_malik_sku AS p1
LEFT JOIN jolly.who_sku_relation AS p2
       ON p1.sku_id = p2.rec_id
;


-- CREDIT_RANK, 信用等级，什么鬼？供应商在我方的信用等级吗？
-- 咳，不用看了，这个字段根本没用起来
SELECT CREDIT_RANK
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
GROUP BY CREDIT_RANK
ORDER BY CREDIT_RANK;
/*
0   3690
1   5
2   4
3   2
    1
*/

-- ORDER_PLATFORM, 1:淘宝,2:天猫,3:独立平台,4:线下采购单,5:1688,6:代拍链接,0:其他
-- 这个其他是什么鬼？有了这个选项，绝大多数都选择了这个类型，太坑了！
SELECT ORDER_PLATFORM
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY ORDER_PLATFORM
ORDER BY ORDER_PLATFORM;
/*
0   1144
1   67
2   19
3   4
4   321
5   271
6   26
7   4
 */

-- DELIVERY_CYCLE, 交货周期，什么单位？天？
SELECT DELIVERY_CYCLE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
GROUP BY DELIVERY_CYCLE
ORDER BY DELIVERY_CYCLE;
/*
0   542
2   1366
3   1616
4   73
5   1
7   1
10  1
    102
 */
-- 多数是2-3天

-- RETURNED_DATE, 退货期限0其他,1一周之内,2半月之内,3一个月内,4三个月内,5不允许退换货
SELECT RETURNED_DATE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
GROUP BY RETURNED_DATE
ORDER BY RETURNED_DATE;
/*
0   246
1   1777
2   527
3   920
4   37
5   95
    100
 */

-- IS_DEPOSIT, 是否有保证金(0,否,1是)
SELECT IS_DEPOSIT
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY IS_DEPOSIT;
/*
1   848
0   1008
 */
-- DEPOSIT, 保证金金额
-- 搞笑嘞，有保证金的，保证金金额为0，跟没有保证金有啥区别嘞

-- SETTLEMENT_TYPE, 结算方式：0：现结；1：周结；2：月结； 3：预付款；4：半月结；5：1.5月结；6：2月结；7：3月结；8：周结现拍
SELECT SETTLEMENT_TYPE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
GROUP BY SETTLEMENT_TYPE
ORDER BY SETTLEMENT_TYPE;
/*
0   1495
1   241
2   1518
3   1
4   398
5   12
6   31
7   3
8   3
 */
-- 不合作的供应商多数是现结的
SELECT SETTLEMENT_TYPE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY SETTLEMENT_TYPE
ORDER BY SETTLEMENT_TYPE;
/*
0   18
1   166
2   1314
4   313
5   12
6   30
7   3
 */
-- 目前多数是月结，还有一部分是半月结和周结

-- PROVINCE, CITY, 供应商所在省市的编码，区域相关表在哪里呢？

-- IS_SYSTEM, 采购是否在供应商系统中处理,1是,0否, 供应商是否用我们的WMS吗？
SELECT IS_SYSTEM
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY IS_SYSTEM;
/*
0   11
1   1845
 */
-- 现在基本都用我方的WMS系统
SELECT IS_SYSTEM
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
GROUP BY IS_SYSTEM;
/*
1   1849
0   1853
 */
-- 以前的供应商多数都不用，大多也取消合作了。

-- SHIPPING_TYPE, 运费方式：1顺丰到付，2包邮，3现付 4跨越到付 3/4怎么理解？跨越还是跨月？
SELECT SHIPPING_TYPE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY SHIPPING_TYPE
ORDER BY SHIPPING_TYPE;
/*
0   1
1   19
2   114
3   946
4   776
 */

-- OOS_DELAY_TIME 缺货超时时间(h) 用来干嘛的？
SELECT OOS_DELAY_TIME
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY OOS_DELAY_TIME
ORDER BY COUNT(*) DESC;
/*
48  1201
36  257
60  154
40  120
72  24
 */
-- 主要是48小时

-- CHECK_TYPE 0未选择、1免检、2抽检、3全检
SELECT CHECK_TYPE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY CHECK_TYPE
ORDER BY CHECK_TYPE;
/*
0   11
1   19
2   114
3   1712
 */
-- 现在几乎都是全检，卖给消费者，应该几乎都要全检才对

-- BUYER_ADMin_ID

-- PUR_DEMAND_PUSH_TIME, 采购需求推送时间
SELECT CODE
        ,SUPP_NAME
        ,FROM_UNIXTIME(PUR_DEMAND_PUSH_TIME)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE PUR_DEMAND_PUSH_TIME >0
LIMIT 30;
/*
1PM YT A爱豪饰品    2017-07-06 08:00:00
1PN ZY M妙响服装    2017-07-06 08:00:00
1PP JE X鑫林电子    2017-07-05 09:20:00
1PQ JE O欧度利方科技  2017-07-06 08:00:00
1PR ZY H初韩服饰    2017-07-06 08:00:00
1PT ZY MMu木木家居馆 2017-07-06 08:00:00
 */
-- 坑，这个字段记录的竟然是最近一次采购需求推送的时间！
SELECT COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE PUR_DEMAND_PUSH_TIME > 0
    AND IS_HIDE = 0;
-- 1856家合作的供应商中，1850家有过采购需求推送，竟然还有6家没推送过？莫非是线下合作方式？
-- 不是的，ORDER_PLATFROM = 4的供应商有300多家
-- 截取一下采购需求推送的时分
WITH T AS
(SELECT CODE
        ,CONCAT_WS(':'
            ,CAST(HOUR(FROM_UNIXTIME(PUR_DEMAND_PUSH_TIME)) AS STRING)
            ,CAST(MINUTE(FROM_UNIXTIME(PUR_DEMAND_PUSH_TIME)) AS STRING)
            ) AS PUSH_TIME
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE PUR_DEMAND_PUSH_TIME >0
    AND IS_HIDE = 0
)
SELECT PUSH_TIME
        ,COUNT(*)
FROM T
GROUP BY PUSH_TIME
ORDER BY COUNT(*) DESC;
/*
8:0 1832
9:30    8
10:0    4
9:0 2
13:30   1
9:40    1
8:30    1
14:0    1
 */
-- 几乎都是8:00推送
-- 截取推送的年月日
WITH T AS
(SELECT CODE
        ,FROM_UNIXTIME(PUR_DEMAND_PUSH_TIME, 'yyyy-MM-dd') AS PUSH_TIME
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE PUR_DEMAND_PUSH_TIME >0
    AND IS_HIDE = 0
)
SELECT PUSH_TIME
        ,COUNT(*)
FROM T
GROUP BY PUSH_TIME
ORDER BY PUSH_TIME DESC;
/*
2017-07-06  1826
2017-07-05  24
 */
-- 看来目前合作的供应商的商品都有销售，这么好吗？

-- ORDER_TYPE 采购类型:0-按需采购,1-备货采购
SELECT ORDER_TYPE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY ORDER_TYPE;
/*
1   75
0   1781
 */
-- 备货采购的话，这个供应商所有的商品都备货采购吗？

-- IS_POP 是否为POP商家:0-否,1-是
SELECT IS_POP
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY IS_POP;
/*
1   1
0   1855
 */
-- 看来这个字段就是一个坑呀，以后只要去IS_POP=0就OK了；

-- MAin_CAT_ID，供应商主营品类
SELECT T1.MAin_CAT_ID
        ,T2.CN_CAT_NAME
        ,COUNT(*) AS SUPP_NUM
FROM JOLLY.WHO_ESOLOO_SUPPLIER T1
LEFT JOIN JOLLY.WHO_CATEGORY T2 ON T1.MAin_CAT_ID = T2.CAT_ID
WHERE T1.IS_HIDE = 0
    AND T1.MAin_CAT_ID > 0
GROUP BY T1.MAin_CAT_ID
        ,T2.CN_CAT_NAME
ORDER BY SUPP_NUM DESC;
/*
2   女装  164
59  鞋   127
35  包   63
31  饰品  53
179 儿童服鞋包饰  46
 */

-- SUPPLIER_NATURE 供应商性质 1、自有工厂 2、经销商 3、OEM贴牌 必填项
SELECT SUPPLIER_NATURE
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY SUPPLIER_NATURE
ORDER BY COUNT(*) DESC;
/*
1   1448
2   372
3   23
    13
 */

-- IS_REAL_TIME_PUSH_PUR_DEMAND 是否实时推送采购需求:0-否,1-是
SELECT IS_REAL_TIME_PUSH_PUR_DEMAND
        ,COUNT(*)
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
GROUP BY IS_REAL_TIME_PUSH_PUR_DEMAND;
-- 这个实时推送貌似并不是真正实时，而是每天早上8:00推送？


-- 供应商地址表 JOLLY.WHO_ESOLOO_SUPPLIER_ADDRESS
-- 这个表貌似不
SELECT *
FROM JOLLY.WHO_ESOLOO_SUPPLIER_ADDRESS
LIMIT 10;

-- 供应商商品类目表
SELECT *
FROM JOLLY.WHO_ESOLOO_SUPPLIER_CAT
LIMIT 10;
-- 供应商一般都有几个类目？
SELECT AVG(CAT_NUM)
FROM
(SELECT SUPP_ID
        ,COUNT(CAT_ID) AS CAT_NUM
FROM JOLLY.WHO_ESOLOO_SUPPLIER_CAT
GROUP BY SUPP_ID) T;
-- 3.13
-- 商品类目最多的供应商TOP30；
SELECT SUPP_ID
        ,COUNT(CAT_ID) AS CAT_NUM
FROM JOLLY.WHO_ESOLOO_SUPPLIER_CAT
GROUP BY SUPP_ID
ORDER BY CAT_NUM DESC
LIMIT 31;
/*
170 46
2392    43
2270    43
1023    41
2398    40
 */
-- 这么多类目，这家企业如果是做生产，这也太。。。
WITH T1 AS
(SELECT CODE
        ,SUPP_NAME
FROM JOLLY.WHO_ESOLOO_SUPPLIER
WHERE IS_HIDE = 0
),
T2 AS
(SELECT CAST(SUPP_ID AS STRING) AS CODE
        ,COUNT(CAT_ID) AS CAT_NUM
FROM JOLLY.WHO_ESOLOO_SUPPLIER_CAT
GROUP BY CAST(SUPP_ID AS STRING)
)
SELECT T1.*
        ,T2.CAT_NUM
FROM T1
LEFT JOIN T2 ON T1.CODE = T2.CODE
WHERE T2.CAT_NUM IS NOT NULL
ORDER BY T2.CAT_NUM DESC;


-- 供应商假期表 WHO_ESOLOO_SUPPLIER_HOLIDAY
SELECT *
FROM JOLLY.WHO_ESOLOO_SUPPLIER_HOLIDAY
LIMIT 10;


-- =============================================== 库存相关数据（顶） ===================================================
/*
 1.库存快照（每天库存记录）
 2.库存变化（出入库记录）
 3.库存位置
 4.库存结构
 */

-- 仓库货位表 ============================================
-- jolly_wms.who_wms_depot_shelf_area
-- jolly.who_wms_depot_shelf_area
-- 去了解：
-- 1.货位具体是什么？
-- 回答：货位是存放商品的地方，以东莞仓为例：DG1-A01-0101
-- DG1：表示东莞1仓
-- A01：A表示A货区，01表示第一排货架
-- 0101：第一个01表示第一列，第二个01表示第一层，即最下面一层


SELECT *
FROM jolly_wms.who_wms_depot_shelf_area
LIMIT 10;
/* 字段说明
shelf_area_id: 主键, 货位id
shelf_area_sn: 货位号，但是我们业务上说的货位号并不指这个，而是库区 - 货位 - 货架
depot_shelf_id：货架id
stock_num：货架总库存
 */

# 沙特仓一共51970个货位
SELECT COUNT(shelf_area_id)
FROM jolly_wms.who_wms_depot_shelf_area;
# CN三仓共519011个货位，这么多吗？
SELECT COUNT(shelf_area_id)
FROM jolly.who_wms_depot_shelf_area;

-- 仓库货架表 =============================================
-- jolly_wms.who_wms_depot_shelf
-- jolly.who_wms_depot_shelf
SELECT *
FROM jolly_wms.who_wms_depot_shelf
LIMIT 10;
/* 字段说明
shelf_id: 主键, 货架id
shelf_sn: 货架号
depot_area_id：货区id
shelf_row：列数
shelf_line：层数
 */

SELECT *
FROM jolly.who_wms_depot_shelf
LIMIT 10;


# 沙特仓一共1549个货架
SELECT COUNT(shelf_id)
FROM jolly_wms.who_wms_depot_shelf;


# 商品库存明细
# 有点诡异，这个表的库存数据是怎么存的？
# 查询总库存为什么要设置开始结束时间？
SELECT *
FROM jolly.who_wms_goods_stock_detail
WHERE stock_num > 0
LIMIT 10;

SELECT COUNT(*)
        ,SUM(stock_num)
FROM jolly.who_wms_goods_stock_detail


SELECT *
FROM jolly.who_wms_goods_stock_total_detail
LIMIT 10;


-- 出入库日志
-- SA仓：jolly_wms.who_wms_goods_stock_detail_log
-- 国内仓：jolly.who_wms_goods_stock_detail_log

# change_type 变更类型
-- 总：1:采购入库,2:收货异常入库,3:销售退货入库,4:盘盈入库, 5:销售订单出库,6:盘亏出库,7:货位转移,8:移库,9:手动入库,10: 移库到亚马逊,11:FBA商品入库,12:库存退货,13:调拨出库,14:上架异常入库,15:调拨入库,16-批发订单入库,17-批发订单出库,18-无订单退货入库,19-报废出库,20 - FBA出库
-- 入库：p1.change_type IN (1, 2, 3, 4, 9, 11, 14, 15, 16, 18)
-- 入库：1:采购入库, 2:收货异常入库, 3:销售退货入库,4:盘盈入库, 9:手动入库, 11:fba商品入库, 14:上架异常入库, 15:调拨入库, 16-批发订单入库,18-无订单退货入库
-- 出库：p1.change_type IN (5, 6, 12, 13, 17, 19, 20)
-- 出库：5:销售订单出库,6:盘亏出库,,12:库存退货,13:调拨出库,17-批发订单出库,18-无订单退货入库,19-报废出库,20 - FBA出库
-- 其他：7:货位转移,8:移库,10: 移库到亚马逊

-- 出库
CASE p1.change_type WHEN 5 THEN '销售订单出库'
                    WHEN 6 THEN '盘亏出库'
                    WHEN 12 THEN '库存退货'
                    WHEN 13 THEN '调拨出库'
                    WHEN 17 THEN '批发订单出库'
                    ELSE '其他'
END


-- SA仓
SELECT depot_id
        ,change_type
        ,SUM(change_num) AS change_num
FROM jolly_wms.who_wms_goods_stock_detail_log
WHERE change_time >= UNIX_TIMESTAMP('2017-08-01', 'yyyy-MM-dd')
    AND change_time < UNIX_TIMESTAMP(FROM_UNIXTIME(UNIX_TIMESTAMP(), 'yyyy-MM-dd'))
    AND depot_id = 7
GROUP BY depot_id
        ,change_type
ORDER BY change_type;

-- Dubai仓
-- 迪拜仓每天出入库量
SELECT FROM_UNIXTIME(p1.change_time, 'yyyy-MM-dd') AS data_date
        ,SUM(CASE WHEN p1.change_type IN (1, 2, 3, 4, 9, 11, 14, 15, 16, 18) THEN p1.change_num ELSE 0 END) AS in_num
        ,SUM(CASE WHEN p1.change_type IN (5, 6, 12, 13, 17, 19, 20) THEN p1.change_num ELSE 0 END) AS out_num
FROM jolly_wms.who_wms_goods_stock_detail_log p1
WHERE p1.depot_id = 15
GROUP BY FROM_UNIXTIME(p1.change_time, 'yyyy-MM-dd')
ORDER BY data_date DESC;


-- SA仓每月出入库商品数
SELECT FROM_UNIXTIME(p1.change_time, 'yyyy-MM') AS data_month
        ,SUM(CASE WHEN p1.change_type IN (1, 2, 3, 4, 9, 11, 14, 15, 16, 18) THEN p1.change_num ELSE 0 END) AS in_num
        ,SUM(CASE WHEN p1.change_type IN (5, 6, 12, 13, 17, 19, 20) THEN p1.change_num ELSE 0 END) AS out_num
FROM jolly_wms.who_wms_goods_stock_detail_log p1
WHERE p1.change_time >= UNIX_TIMESTAMP('2017-01-01')
  AND p1.change_time < UNIX_TIMESTAMP('2018-01-01')
GROUP BY FROM_UNIXTIME(p1.change_time, 'yyyy-MM')
ORDER BY data_month;



-- 东莞仓昨日出入库和库存统计 ========================================================================
WITH
-- 1.出入库数量
t1 AS
(SELECT FROM_UNIXTIME(p1.change_time, 'yyyyMMdd') AS data_date
        ,p1.depot_id
        ,p2.depot_area_sn
        -- 1.1 出库各类型数量
        ,SUM(CASE p1.change_type WHEN 5 THEN p1.change_num ELSE 0 END) AS out_num_xiaoshou
        ,SUM(CASE p1.change_type WHEN 6 THEN p1.change_num ELSE 0 END) AS out_num_pankui
        ,SUM(CASE p1.change_type WHEN 12 THEN p1.change_num ELSE 0 END) AS out_num_tuihuo
        ,SUM(CASE p1.change_type WHEN 13 THEN p1.change_num ELSE 0 END) AS out_num_diaobo
        ,SUM(CASE p1.change_type WHEN 17 THEN p1.change_num ELSE 0 END) AS out_num_pifa
        ,SUM(CASE p1.change_type WHEN 19 THEN p1.change_num ELSE 0 END) AS out_num_baofei
        ,SUM(CASE p1.change_type WHEN 20 THEN p1.change_num ELSE 0 END) AS out_num_FBA
        ,SUM(CASE WHEN p1.change_type IN (5, 6, 12, 13, 17, 19, 20) THEN p1.change_num ELSE 0 END) AS out_num_total
        -- 1.2 入库各类型数量
        ,SUM(CASE p1.change_type WHEN 1 THEN p1.change_num ELSE 0 END) AS in_num_caigou
        ,SUM(CASE p1.change_type WHEN 2 THEN p1.change_num ELSE 0 END) AS in_num_shouhuoyichang
        ,SUM(CASE p1.change_type WHEN 3 THEN p1.change_num ELSE 0 END) AS in_num_xiaoshoutuihuo
        ,SUM(CASE p1.change_type WHEN 4 THEN p1.change_num ELSE 0 END) AS in_num_panying
        ,SUM(CASE p1.change_type WHEN 9 THEN p1.change_num ELSE 0 END) AS in_num_shoudong
        ,SUM(CASE p1.change_type WHEN 11 THEN p1.change_num ELSE 0 END) AS in_num_FBA
        ,SUM(CASE p1.change_type WHEN 14 THEN p1.change_num ELSE 0 END) AS in_num_shangjiayichang
        ,SUM(CASE p1.change_type WHEN 15 THEN p1.change_num ELSE 0 END) AS in_num_diaobo
        ,SUM(CASE p1.change_type WHEN 16 THEN p1.change_num ELSE 0 END) AS in_num_pifa
        ,SUM(CASE p1.change_type WHEN 18 THEN p1.change_num ELSE 0 END) AS in_num_wudingdan
        ,SUM(CASE WHEN p1.change_type IN (1, 2, 3, 4, 9, 11, 14, 15, 16, 18) THEN p1.change_num ELSE 0 END) AS in_num_total
FROM jolly.who_wms_goods_stock_detail_log AS p1
LEFT JOIN jolly.who_wms_depot_area AS p2
       ON p1.depot_area_id = p2.depot_area_id
WHERE p1.change_time >= UNIX_TIMESTAMP('2018-01-15')
  AND p1.change_time < UNIX_TIMESTAMP('2018-01-16')
  AND p1.depot_id IN (5, 14)
GROUP BY FROM_UNIXTIME(p1.change_time, 'yyyyMMdd')
        ,p1.depot_id
        ,p2.depot_area_sn
),

-- 2.库存量-总库存
t2 AS
(SELECT p1.data_date
        ,p1.depot_id
        ,p2.depot_area_sn
        ,SUM(p1.stock_num) AS total_stock_num
FROM zydb.ods_who_wms_goods_stock_detail AS p1
LEFT JOIN jolly.who_wms_depot_area AS p2
       ON p1.depot_area_id = p2.depot_area_id
WHERE p1.depot_id IN (5, 14)
  AND p1.data_date >= '20180115'
  AND p1.data_date < '20180116'
GROUP BY p1.data_date
        ,p1.depot_id
        ,p2.depot_area_sn
),
-- 3.库存量-自由库存
-- 自由库存快照表中没有货位号，所以去查询

-- 4.合并1和2
t0 AS
(SELECT t2.*
        ,t1.out_num_xiaoshou
        ,t1.out_num_pankui
        ,t1.out_num_tuihuo
        ,t1.out_num_diaobo
        ,t1.out_num_pifa
        ,t1.out_num_baofei
        ,t1.out_num_FBA
        ,t1.out_num_total
        ,t1.in_num_caigou
        ,t1.in_num_shouhuoyichang
        ,t1.in_num_xiaoshoutuihuo
        ,t1.in_num_panying
        ,t1.in_num_shoudong
        ,t1.in_num_FBA
        ,t1.in_num_shangjiayichang
        ,t1.in_num_diaobo
        ,t1.in_num_pifa
        ,t1.in_num_wudingdan
        ,t1.in_num_total
FROM t2
LEFT JOIN t1
       ON t1.data_date = t2.data_date
      AND t1.depot_id = t2.depot_id
      AND t1.depot_area_sn = t2.depot_area_sn
)

-- 前10条记录
SELECT *
FROM t0
LIMIT 10;



-- 每天采购入库
SELECT FROM_UNIXTIME(change_time, 'yyyy-MM-dd') AS change_date
        ,SUM(change_num) AS change_num
FROM jolly_wms.who_wms_goods_stock_detail_log
WHERE change_time >= UNIX_TIMESTAMP('2017-08-01', 'yyyy-MM-dd')
    AND change_time < UNIX_TIMESTAMP('2017-09-01', 'yyyy-MM-dd')
    AND depot_id = 7
    AND change_type = 1
GROUP BY FROM_UNIXTIME(change_time, 'yyyy-MM-dd')
ORDER BY change_date;


# change_type 变更类型 1:采购入库,2:收货异常入库,3:销售退货入库,4:盘盈入库, 5:销售订单出库,6:盘亏出库,7:货位转移,8:移库,9:手动入库,10: 移库到亚马逊,11:fba商品入库,12:库存退货,13:调拨出库,14:上架异常入库,15:调拨入库,16-批发订单入库,17-批发订单出库

WITH
t1 AS
(SELECT (CASE WHEN p1.change_type = 1 THEN '采购入库'
                            WHEN p1.change_type = 2 THEN '收货异常入库'
                            WHEN p1.change_type = 3 THEN '销售退货入库'
                            WHEN p1.change_type = 4 THEN '盘盈入库'
                            WHEN p1.change_type = 9 THEN '手动入库'
                            WHEN p1.change_type = 11 THEN 'FBA商品入库'
                            WHEN p1.change_type = 14 THEN '上架异常入库'
                            WHEN p1.change_type = 15 THEN '调拨入库'
                            WHEN p1.change_type = 16 THEN '批发订单入库'
                            WHEN p1.change_type = 18 THEN '无订单退货入库'
                            WHEN p1.change_type = 5 THEN '销售订单出库'
                            WHEN p1.change_type = 6 THEN '盘亏出库'
                            WHEN p1.change_type = 12 THEN '库存退货'
                            WHEN p1.change_type = 13 THEN '调拨出库'
                            WHEN p1.change_type = 17 THEN '批发订单出库'
                            ELSE '其他' END) AS change_type2
        ,(CASE WHEN p1.change_type IN (1, 2, 3, 4, 9, 11, 14, 15, 16, 18) THEN 'IN'
                      WHEN p1.change_type IN (5, 6, 12, 13, 17) THEN 'OUT'
                      ELSE 'Others' END) AS change_type1
        ,p2.cat_level1_name
        ,FROM_UNIXTIME(p1.change_time, 'yyyy-MM') AS change_month
        ,FROM_UNIXTIME(p1.change_time, 'yyyy-MM-dd') AS change_date
        ,SUM(p1.change_num) AS change_num
FROM jolly_wms.who_wms_goods_stock_detail_log p1
LEFT JOIN zydb.dim_jc_goods p2
             ON p1.goods_id = p2.goods_id
WHERE p1.depot_id = 7
     AND p1.change_time >= UNIX_TIMESTAMP('2017-07-01')
     AND p1.change_time < UNIX_TIMESTAMP('2017-10-01')
GROUP BY (CASE WHEN p1.change_type = 1 THEN '采购入库'
                            WHEN p1.change_type = 2 THEN '收货异常入库'
                            WHEN p1.change_type = 3 THEN '销售退货入库'
                            WHEN p1.change_type = 4 THEN '盘盈入库'
                            WHEN p1.change_type = 9 THEN '手动入库'
                            WHEN p1.change_type = 11 THEN 'FBA商品入库'
                            WHEN p1.change_type = 14 THEN '上架异常入库'
                            WHEN p1.change_type = 15 THEN '调拨入库'
                            WHEN p1.change_type = 16 THEN '批发订单入库'
                            WHEN p1.change_type = 18 THEN '无订单退货入库'
                            WHEN p1.change_type = 5 THEN '销售订单出库'
                            WHEN p1.change_type = 6 THEN '盘亏出库'
                            WHEN p1.change_type = 12 THEN '库存退货'
                            WHEN p1.change_type = 13 THEN '调拨出库'
                            WHEN p1.change_type = 17 THEN '批发订单出库'
                            ELSE '其他' END)
        ,(CASE WHEN p1.change_type IN (1, 2, 3, 4, 9, 11, 14, 15, 16, 18) THEN 'IN'
                      WHEN p1.change_type IN (5, 6, 12, 13, 17) THEN 'OUT'
                      ELSE 'Others' END)
        ,p2.cat_level1_name
        ,FROM_UNIXTIME(p1.change_time, 'yyyy-MM')
        ,FROM_UNIXTIME(p1.change_time, 'yyyy-MM-dd')
)
-- 每月每天出库量
SELECT change_month
        ,change_date
        ,SUM(change_num) AS change_num
FROM t1
WHERE change_type1 = 'OUT'
GROUP BY change_month
        ,change_date
ORDER BY change_month
        ,change_date;
-- 各一级类目的出入库商品数量
SELECT *
FROM t1
ORDER BY cat_level1_name
        ,change_month
        ,change_type1
        ,change_type2
;


# 库存快照表：zydb.ods_who_wms_goods_stock_detail
# 每天一个快照，几点的？

zydb.ods_who_wms_goods_stock_detail；zydb.ods_who_wms_goods_stock_total_detail

SELECT *
FROM zydb.ods_who_wms_goods_stock_detail
LIMIT 10;

-- 查询昨天各二级类目的库存占比
WITH
-- 每个商品的库存
t1 AS
(SELECT p1.data_date
        ,p1.goods_id
        ,p2.cat_level1_name AS cat1_name
        ,p2.cat_level2_name AS cat2_name
        ,CONCAT_WS(' - ', p2.cat_level1_name, p2.cat_level2_name) AS cat12_name
        ,stock_num
FROM zydb.ods_who_wms_goods_stock_detail p1
LEFT JOIN zydb.dim_jc_goods p2 ON p1.goods_id = p2.goods_id
WHERE p1.data_date >= '20170701'
     AND p1.data_date <= '20170831'
)
SELECT t1.data_date
        ,t1.cat1_name
        ,SUM(stock_num) AS stock_num
FROM t1
GROUP BY t1.data_date
        ,t1.cat1_name
ORDER BY t1.data_date
        ,t1.cat1_name;

/*
-- 采购调拨在途库存（cn + sa）
-- jolly.who_wms_goods_stock_onway_total
-- 分区表zydb.ods_wms_goods_stock_onway_total，分区字段data_date = 20170820
 */
SELECT depot_id
        ,SUM(allocate_order_onway_num + pur_shiped_order_onway_num + pur_order_onway_num) AS pur_allocate_onway_num
FROM jolly.who_wms_goods_stock_onway_total
WHERE depot_id IN (4, 5, 6)
GROUP BY depot_id;



----------------- 各仓库总库存和自由库存，历史和当前值取法
-- 1. 求总库存：
-- zydb.ods_who_wms_goods_stock_detail.stock_num (当前最新和历史每天快照)

-- 2.求自由库存：
-- 2.1 zydb.ods_who_wms_goods_stock_total_detail (data FROM 201704) (当前最新和历史每天快照)，表中20170813-20170822的库存数据可能不太准确
-- 2.2 jolly.who_wms_goods_stock_total_detail (当前最新)
-- free_num = total_stock_num - total_order_lock_num - total_allocate_lock_num - total_return_lock_num

*******************************
沙特仓，求总库存: (hadoop)   jolly_wms.who_wms_goods_stock_detail    stock_num     (可以查：当前最新)  --无法求沙特历史某天快照总库存

沙特仓，求自由库: (hadoop)   jolly_wms.who_wms_goods_stock_total_detail            (可以查：当前最新)
free_num= total_stock_num-total_order_lock_num-total_allocate_lock_num-total_return_lock_num

jolly_wms.who_wms_goods_stock_total_detail_daily      (可以查：当前最新和历史每天快照)
                     free_num= total_stock_num-total_order_lock_num-total_allocate_lock_num-total_return_lock_num

zydb.ods_who_wms_goods_stock_detail

-- 查询SA仓正品库存
-- jolly_wms.who_wms_depot_area
-- jolly_wms.who_wms_goods_stock_detail

SELECT SUM(stock_num)
FROM jolly_wms.who_wms_goods_stock_detail p1
LEFT JOIN jolly_wms.who_wms_depot_area p2
             ON p1.depot_area_id = p2.depot_area_id
WHERE p2.depot_area_type_id = 1
;

-- 查询国内仓正品库存
SELECT p1.depot_id
        ,SUM(stock_num) AS total_stock_num
        ,SUM(CASE WHEN p2.depot_area_type_id = 1 THEN stock_num ELSE 0 END) AS good_stock_num         -- 正品库存
        ,SUM(CASE WHEN p2.depot_area_type_id = 1 THEN 0 ELSE stock_num END) AS bad_stock_num         -- 次品库存
FROM jolly.who_wms_goods_stock_detail p1
LEFT JOIN jolly.who_wms_depot_area p2
             ON p1.depot_area_id = p2.depot_area_id
GROUP BY p1.depot_id
ORDER BY p1.depot_id
;


-- 库存
--每日各仓某时刻 自由库存统计
SELECT t.depot_id,COUNT(DISTINCT t.goods_id), SUM(t.free_num)
FROM
(--  CN仓
SELECT depot_id,goods_id,sku_id,
SUM(total_stock_num) total_stock_num,
SUM(total_stock_num-total_order_lock_num-total_allocate_lock_num-total_return_lock_num) free_num
FROM  jolly.who_wms_goods_stock_total_detail s  -- 历史自由库存  201704开始 -zydb.ods_who_wms_goods_stock_total_detail
WHERE 1=1
AND depot_id IN (4,5,6)
AND total_stock_num-total_order_lock_num-total_allocate_lock_num-total_return_lock_num>0
GROUP BY depot_id, goods_id,sku_id
) t
GROUP BY t.depot_id
union all
SELECT t.depot_id,COUNT(DISTINCT t.goods_id), SUM(t.free_num)
FROM
(--  SA仓
SELECT depot_id,goods_id,sku_id,
SUM(total_stock_num) total_stock_num,
SUM(total_stock_num-total_order_lock_num-total_allocate_lock_num-total_return_lock_num) free_num
FROM  jolly_wms.who_wms_goods_stock_total_detail s --历史自由库存 ？jolly_wms.who_wms_goods_stock_total_detail_daily
WHERE 1=1
AND depot_id =7
AND total_stock_num-total_order_lock_num-total_allocate_lock_num-total_return_lock_num>0
GROUP BY depot_id, goods_id,sku_id
) t
GROUP BY t.depot_id

----各仓库每日进出
SELECT TO_DATE(FROM_UNIXTIME(change_time)) data_date,
SUM(CASE WHEN  change_type=1 THEN change_num END) 备货入库件数,
SUM(CASE WHEN  change_type=3 THEN change_num END) 退货入库件数 ,
SUM(CASE WHEN  change_type=5 THEN change_num END) 销售出库件数
FROM jolly_wms.who_wms_goods_stock_detail_log  a
WHERE 1=1
AND FROM_UNIXTIME(change_time,'yyyyMMdd')>='20170701'
AND FROM_UNIXTIME(change_time,'yyyyMMdd')< '20170717'
GROUP BY TO_DATE(FROM_UNIXTIME(change_time))


-- 仓库每天总库存
SELECT SUBSTR(p1.data_date, 1, 6) AS month
        ,p1.data_date
        ,SUM(p1.total_stock_num) AS stock_num
FROM zydb.ods_who_wms_goods_stock_total_detail p1
WHERE p1.data_date >= '20170701'
     AND p1.data_date <= '20170930'
     AND p1.depot_id = 6
GROUP BY SUBSTR(p1.data_date, 1, 6)
        ,p1.data_date
;

-- SA仓每天总库存数量和成本金额
SELECT ds
        ,SUM(p1.total_stock_num) AS total_stock_num
        ,SUM(p1.total_stock_num * p2.in_price) AS totck_stock_cost
FROM jolly_wms.who_wms_goods_stock_total_detail_daily p1
LEFT JOIN zydb.dim_jc_goods p2 ON p1.goods_id = p2.goods_id
WHERE ds >= '20170501'
     AND depot_id = 7
GROUP BY ds
ORDER BY ds;





-- =============================================== 库存相关数据（底） ===================================================


















/*
-- 在库库存
-- cn仓 jolly.who_wms_goods_stock_total_detail
-- sa仓 jolly_wms.who_wms_goods_stock_total_detail
 */
-- 总库存
WITH
-- cn仓在库库存
t1 AS
(SELECT depot_id
        ,SUM(total_stock_num) AS total_stock_num
FROM jolly.who_wms_goods_stock_total_detail
WHERE depot_id IN (4, 5, 6)
GROUP BY depot_id
),
-- sa仓
t2 AS
(SELECT depot_id
        ,SUM(total_stock_num) AS total_stock_num
FROM jolly_wms.who_wms_goods_stock_total_detail
GROUP BY depot_id
)
-- union
SELECT t1.* FROM t1
uniON
SELECT t2.* FROM t2;

-- 自由库存
WITH
-- cn仓在库库存
t1 AS
(SELECT depot_id
        ,SUM(total_stock_num - total_order_lock_num - total_allocate_lock_num - total_return_lock_num) AS total_free_stock_num
FROM jolly.who_wms_goods_stock_total_detail
WHERE depot_id IN (4, 5, 6)
GROUP BY depot_id
),
-- sa仓
t2 AS
(SELECT depot_id
        ,SUM(total_stock_num) AS total_stock_num
FROM jolly_wms.who_wms_goods_stock_total_detail
GROUP BY depot_id
)
-- union
SELECT t1.* FROM t1
uniON
SELECT t2.* FROM t2;


-- 退货
-- 以下计算方式并未核实

SELECT return_status
        ,COUNT(*)
        ,SUM(returned_goods_num) AS returned_num
FROM jolly.who_wms_returned_order_info
GROUP BY return_status
ORDER BY return_status;

-- 退货在途计算方式一
SELECT p2.returned_depot_id
    ,COUNT(*)
    ,SUM(p1.returned_num)
FROM jolly.who_wms_returned_order_goods p1
LEFT JOIN jolly.who_wms_returned_order_info p2 ON p1.returned_rec_id = p2.returned_rec_id
WHERE p1.stock_END_time = UNIX_TIMESTAMP('1970-01-01 08:00:00')
GROUP BY p2.returned_depot_id;
-- 数据太大，不太靠谱
/*
4   5946345 6447107
7   1040863 1100934
    10  13
 */

-- 计算方式二
SELECT p2.returned_depot_id
        ,SUM(returned_num)
FROM jolly.who_wms_returned_order_goods p1
LEFT JOIN jolly.who_wms_returned_order_info p2 ON p1.returned_rec_id = p2.returned_rec_id
WHERE p1.is_stock = 0
GROUP BY p2.returned_depot_id
ORDER BY p2.returned_depot_id;
-- 数据太大，也不靠谱
/*
4   6728369.0
7   2337678.0
    13.0
 */

-- 计算方式三
SELECT returned_depot_id
        ,SUM(returned_goods_num) AS return_onway_num
FROM jolly.who_wms_returned_order_info
WHERE return_status = 1 or return_status = 3
GROUP BY returned_depot_id
ORDER BY returned_depot_id;
-- 没那么离谱了
/*
4   998236.0
7   908689.0
 */

-- 计算方式四
WITH
-- 退货在途的退货单
t1 AS
(SELECT returned_rec_id
        ,returned_depot_id
FROM jolly.who_wms_returned_order_info
WHERE return_status = 1 or return_status = 3
GROUP BY returned_rec_id
        ,returned_depot_id
)
SELECT t1.returned_depot_id
        ,SUM(p1.returned_num) AS returned_onway_num
FROM t1
LEFT JOIN jolly.who_wms_returned_order_goods p1 ON t1.returned_rec_id = p1.returned_rec_id
GROUP BY t1.returned_depot_id
ORDER BY t1.returned_depot_id;
/*
7   920999
4   1037130
 */









-- 内购商品cn仓自由库存
WITH
t1 AS
(SELECT p1.sku_id
        ,p1.depot_id
        ,p1.depot_area_id
        ,p1.shelf_id
        ,p1.shelf_area_id
        ,CONCAT_WS('-', cASt(p1.depot_area_id AS string),
                                        cASt(p1.shelf_id AS string),
                                        cASt(p1.shelf_area_id AS string)) AS depot_shelf_id
        ,p1.stock_num
        ,(p1.stock_num - p1.order_lock_num - p1.lock_allocate_num - p1.return_lock_num) AS free_num
FROM jolly.who_wms_goods_stock_detail p1
WHERE p1.depot_id IN (4, 5, 6)
    AND p1.sku_id IN (118210,309684,344302,1587192,1657288,1802762,1827808,1828072,1853206,1943172,2054688,2081684,2141352,2164894,2240496,2277088,2277684,2320616,2388020,2449794,2485078,2485082,2486374,2501668,2567744,2568776,2578082,2580830,2612404,2653362,2699302,2699322,2742776,2769348,2783792,2784378,2834970,2881580,2892288,2942610,2944058,2944352,2967524,3011176,3034698,3054562,3055138,3100974,3111650,3214758,3227548,799993,800149,807153,857577,1044995,3248202,3302704,1159535,1176017,1201427,1201429,3382184,3598636,3841414,5290654,1813116,1813118,1813120,1813122,1813124,1815044,1858182,2285162,3051878,3124914,1615482,2429186,2431114,1614226,347804,309652)
),
-- 关联得到shelf_area_sn
t2 AS
(SELECT t1.*
        ,p1.shelf_area_sn
FROM t1
LEFT JOIN jolly.who_wms_picking_goods_detail p1 ON t1.shelf_area_id = p1.shelf_area_id
)
-- 结果表
SELECT sku_id
        ,depot_id
        ,depot_shelf_id
        ,shelf_area_sn
        ,SUM(stock_num) AS stock_num
        ,SUM(free_num) AS free_num
FROM t2
GROUP BY sku_id
        ,depot_id
        ,depot_shelf_id
        ,shelf_area_sn;


-- jolly.who_wms_goods_stock_total_detail
-- jolly_oms.who_wms_goods_stock_total_detail
-- zydb.ods_who_wms_goods_stock_total_detail
WITH
-- wms
t1 AS
(SELECT depot_id
        ,sku_id
        ,total_stock_num
        ,total_order_lock_num
        ,total_allocate_lock_num
        ,total_return_lock_num
        ,'wms' AS source
FROM jolly.who_wms_goods_stock_total_detail
WHERE sku_id = 6173662
),
-- zydb
t2 AS
(SELECT depot_id
        ,sku_id
        ,total_stock_num
        ,total_order_lock_num
        ,total_allocate_lock_num
        ,total_return_lock_num
        ,'zydb' AS source
FROM zydb.ods_who_wms_goods_stock_total_detail
WHERE sku_id = 6173662
  AND data_date = '20170822'
)
SELECT * FROM t1
uniON all
SELECT * FROM t2
;





-- 查询sku在各个货位号的库存
WITH
-- 库存明细
t1 AS
(SELECT e.depot_id
        ,e.sku_id
        ,concat(d.depot_sn,'-',c.depot_area_sn,b.shelf_sn,'-',a.shelf_area_sn) AS shelf_area_sn
        ,(e.stock_num - e.order_lock_num - e.lock_allocate_num - e.return_lock_num) AS free_num
FROM jolly.who_wms_depot_shelf_area a
        ,jolly.who_wms_depot_shelf b
        ,jolly.who_wms_depot_area c
        ,jolly.who_wms_depot d
        ,jolly.who_wms_goods_stock_detail e
WHERE a.depot_shelf_id = b.shelf_id
     AND b.depot_area_id = c.depot_area_id
     AND c.depot_id = d.depot_id
     AND a.shelf_area_id = e.shelf_area_id
     AND e.stock_num >0
     AND e.depot_id IN (4, 5, 6)
),
--  sku与货位号的数量，看是否有sku在多个货位上
t2 AS
(SELECT sku_id
        ,COUNT(shelf_area_sn) AS shelf_num
FROM t1
GROUP BY sku_id
)
-- 结果，看有多少sku在多个货位上有库存
SELECT COUNT (sku_id)
FROM t2
WHERE shelf_num >=2;
-- 有8000多个sku
SELECT *
FROM t1
LIMIT 10;


/*
以下代码查询物流相关信息，包括承运商信息，订单物流状态等
主要数据表：
-- 订单派送跟踪表: jolly.who_order_shipping_tracking
-- 订单到达目的国时间: jolly.who_prs_cod_order_shipping_time
 */

-- 订单派送跟踪表: jolly.who_order_shipping_tracking
SELECT *
FROM jolly.who_order_shipping_tracking
LIMIT 10;
-- INvoice_no: 物流编号
-- status: 监控状态: polling:监控中，shutdown:结束，abort:中止，updateall：重新推送。其中当快递单为已签收时status=shutdown，当message为“3天查询无记录”或“60天无变化时”status= abort
SELECT status
        ,COUNT(order_id)
FROM jolly.who_order_shipping_tracking
GROUP BY status;
/*
1   polling 344657
2   shutdown    3189839
3   abort   645319
4   issend  2350
5   updateall   2720
 */
-- shipping_state 0在途中、1已揽收、2疑难、3已签收、4退签、5同城派送中、6退回（客户退回，未签收承运商退回，投递失败退回等）、7转单、8已拒收、13货丢了 等9个状态
3—签收
6/8—拒收退回
!=3/6/8/13—挂起
-- 问题：实际查询出来有15个值，9-13及110的含义分别是什么？
-- 其余取值可能是新功能暂未上线，后期可以逐一核实
SELECT shipping_state
        ,COUNT(order_id)
FROM jolly.who_order_shipping_tracking
GROUP BY shipping_state
ORDER BY shipping_state;
/*
1   0   527893
2   1   5617
3   2   28255
4   3   3189800
5   4   68
6   5   3344
7   6   406922
8   7   2720
9   8   1368
10  9   5773
11  10  2754
12  11  7694
13  12  70
14  13  257
15  110 2350
 */
-- result_type: 结果归类：1、地址不详 2、地址错误 3、派送无人 4、收件人拒收 5、其他
SELECT result_type
        ,COUNT(order_id)
FROM jolly.who_order_shipping_tracking
GROUP BY result_type
ORDER BY result_type;
/*
1   0   2088228
2   1   38
3   2   102
4   3   462
5   4   1316
6   5   2094739
 */
-- tracking_code
-- result_code

-- 订单到达目的国时间: jolly.who_prs_cod_order_shipping_time
-- 注意：destination_time才是真正的到达目的国时间
SELECT *
FROM jolly.who_prs_cod_order_shipping_time
LIMIT 10;







-- 承运商
SELECT real_shipping_id
        ,real_shipping_name
FROM jolly.who_order_info
WHERE real_shipping_id IN (40, 168, 170, 172, 174, 176)
GROUP BY real_shipping_id
        ,real_shipping_name
ORDER BY real_shipping_id;


-- 采购单物流信息表
-- jolly.who_wms_pur_order_tracking_info
SELECT *
FROM jolly.who_wms_pur_order_tracking_info
LIMIT 10;
-- 问题：运费支付方式tracking_pay_type取值含义
-- 0/1/2/3/4







/*
1.1个拣货单中可以包含多张订单的商品
2.1个订单的商品可能分散到多个拣货单中进行拣货
3.关联关系：jolly.who_wms_picking_info.picking_id = jolly.who_wms_picking_goods_detail.picking_id
4.picking_finish_time：jolly.who_wms_picking_info.finish_time
5.当一张订单中的商品拆成多张拣货单来拣货时，最后完成拣货的那个时间才是该订单的完成拣货时间
*/

/*
有趣的问题：
1.一个订单一般拆成多少个拣货单？
2.一个拣货单一般包含多少个订单？
3.一个拣货单一般拣多少件商品？
4.一个拣货单一般花多长时间完成？
5.一个订单一般花多长时间完成拣货？
*/

-- 拣货单信息表
SELECT * FROM jolly.who_wms_picking_info LIMIT 10;

-- 拣货商品明细表
SELECT * FROM jolly.who_wms_picking_goods_detail LIMIT 10;

-- 查询某张订单的拣货信息
SELECT a.order_sn, a.picking_id, b.finish_time
FROM jolly.who_wms_picking_goods_detail a
LEFT JOIN jolly.who_wms_picking_info b ON a.picking_id = b.picking_id
WHERE a.order_sn = 'arsi201612190456301526';

-- 查询某张订单分几次分拣
SELECT COUNT(DISTINCT picking_id) AS pick_num
FROM jolly.who_wms_picking_goods_detail
WHERE order_sn = 'arsi201612190456301526';

-- 查询各仓库拣货单数量
SELECT depot_id, COUNT(picking_id) AS pick_num
FROM jolly.who_wms_picking_info
GROUP BY depot_id;

-- 查询order_COUNT的拣货单数量
SELECT order_COUNT, COUNT(picking_id) AS pick_num
FROM jolly.who_wms_picking_info
GROUP BY order_COUNT
ORDER BY pick_num desc;




-- 订单信息表who_order_info
-- prepare_pay_time这个字段是怎么存的？具体含义是什么？
SELECT
(CASE WHEN pay_id = 41 THEN 'cod' ELSE 'ncod' END) AS pay_id2,
(CASE WHEN prepare_pay_time = 0 THEN 0 ELSE 1 END) AS prepare_pay_time2,
COUNT(order_sn) AS order_num
FROM jolly.who_order_info
GROUP BY
(CASE WHEN pay_id = 41 THEN 'cod' ELSE 'ncod' END),
(CASE WHEN prepare_pay_time = 0 THEN 0 ELSE 1 END);




SELECT substr(order_sn, 0, 3) AS order_sn
        ,COUNT(order_sn)
FROM zybi.dw_order_sub_order_fact
GROUP BY substr(order_sn, 0, 3)
ORDER BY COUNT(order_sn) desc;





-- 查询采购单对应的物流单数
WITH t AS
(SELECT pur_order_sn
    ,COUNT(DISTINCT tracking_no) AS tracking_no
FROM zydb.ods_wms_pur_deliver_receipt
GROUP BY pur_order_sn
)
SELECT tracking_no
    ,COUNT(pur_order_sn) AS order_no
FROM t
GROUP BY tracking_no
ORDER BY tracking_no;

-- 查询物流单对应的采购单数
WITH t AS
(SELECT tracking_no
    ,COUNT(DISTINCT pur_order_sn) AS order_no
FROM zydb.ods_wms_pur_deliver_receipt
GROUP BY tracking_no
)
SELECT order_no
    ,COUNT(tracking_no) AS tracking_no
FROM t
GROUP BY order_no
ORDER BY order_no;



-- 沙特仓需求，20170719
-- 每天发运到各个城市的订单数量；
WITH
-- 沙特仓每天发运的订单明细
t1 AS
(SELECT FROM_UNIXTIME(shipping_time, 'yyyy-MM-dd') AS ship_date
        ,order_id
FROM jolly.who_order_info
WHERE is_shiped = 1
    AND depot_id = 7
    AND shipping_time >= UNIX_TIMESTAMP('2017-07-15', 'yyyy-MM-dd')
    AND shipping_time <= UNIX_TIMESTAMP('2017-07-19', 'yyyy-MM-dd')
),
-- 获取每个城市的名称
t2 AS
(SELECT region_id
        ,region_name
FROM jolly.who_region
WHERE region_type = 2
    AND region_status = 1
),
-- 关联jolly.who_order_user_info和t2，得到订单发往的城市名称
t3 AS
(SELECT t1.*
        ,t2.region_name AS city_name
FROM t1
LEFT JOIN jolly.who_order_user_info p1 ON t1.order_id = p1.order_id
LEFT JOIN t2 ON p1.city = t2.region_id
),
-- 结果表
t AS
(SELECT ship_date
        ,city_name
        ,COUNT(*) AS order_num
FROM t3
GROUP BY ship_date
        ,city_name
)
-- 查询部分数据
SELECT *
FROM t
ORDER BY ship_date desc
        ,order_num desc;


-- 查询某个国家的所有城市(子查询方式)
WITH
-- 先查询所有省份
t1 AS
(SELECT region_id
FROM jolly.who_region
WHERE parent_id = 1876
    AND region_type = 1
)
-- 查询所有城市
SELECT region_id
        ,region_name
FROM jolly.who_region
WHERE parent_id IN (SELECT * FROM t1)
    AND region_type = 2



SELECT p1.order_id
        ,p1.pay_id
        ,p1.cod_check_status
        ,p1.shipping_status
        ,p2.shipping_state
FROM jolly.who_order_info p1
LEFT JOIN jolly.who_order_shipping_tracking p2
            ON p1.order_id = p2.order_id
WHERE p1.order_status = 1
    AND p1.pay_status = 1
    AND p1.is_shiped = 1
LIMIT 10;

-- 每天销售数量
WITH t1 AS
(SELECT p1.*
        ,decode(prepare_pay_time = 0, pay_time, prepare_pay_time) AS real_pay_time
FROM jolly.who_order_info p1
WHERE p1.order_status = 1
    AND p1.pay_status IN (1, 3)
)
SELECT FROM_UNIXTIME(real_pay_time, 'yyyy-MM-dd') AS real_pay_date
        ,SUM(goods_num) AS goods_num
FROM t1
WHERE t1.real_pay_time >= UNIX_TIMESTAMP('2017-04-01')
GROUP BY FROM_UNIXTIME(real_pay_time, 'yyyy-MM-dd')
ORDER BY real_pay_date;


-- 沙特仓每天每个小时可拣货订单数
SELECT TO_DATE(P1.outing_stock_time) AS outing_stock_date
        ,SUBSTR(P1.outing_stock_time, 12, 2) AS outing_stock_hour
        ,COUNT(P1.order_id) AS order_num
FROM zydb.dw_order_node_time AS p1
WHERE is_shiped = 1
  AND depot_id = 7
  AND outing_stock_time >= '2018-01-01'
  AND outing_stock_time <  '2018-02-01'
GROUP BY TO_DATE(P1.outing_stock_time)
        ,SUBSTR(P1.outing_stock_time, 12, 2)
ORDER BY outing_stock_date
        ,outing_stock_hour;


-- 沙特仓每天每个小时客户下单数
WITH t AS
(SELECT *
        ,(CASE WHEN prepare_pay_time = 0 THEN pay_time ELSE prepare_pay_time END) AS real_pay_time
FROM jolly.who_order_info
WHERE depot_id = 7
     AND order_status = 1
     AND pay_status IN (1, 3)
),
t2 AS
(SELECT FROM_UNIXTIME(real_pay_time, 'yyyy-MM-dd') AS date_BeiJing
        ,FROM_UNIXTIME(real_pay_time, 'HH') AS hour_BeiJing
        ,COUNT(order_id) AS order_num
FROM t
WHERE real_pay_time >= UNIX_TIMESTAMP('2017-06-01', 'yyyy-MM-dd')
    AND real_pay_time <= UNIX_TIMESTAMP('2017-08-29', 'yyyy-MM-dd')
GROUP BY FROM_UNIXTIME(real_pay_time, 'yyyy-MM-dd')
        ,FROM_UNIXTIME(real_pay_time, 'HH')
ORDER BY date_BeiJing
        ,hour_BeiJing
),

-- 沙特仓每天每个小时配货完成订单数（可拣货）
t3 AS
(SELECT FROM_UNIXTIME(gmt_created, 'yyyy-MM-dd') AS date_BeiJing
        ,FROM_UNIXTIME(gmt_created, 'HH') AS hour_BeiJing
        ,COUNT(DISTINCT order_id) AS order_num
FROM jolly_wms.who_wms_outing_stock_detail
WHERE depot_id = 7
    AND gmt_created >= UNIX_TIMESTAMP('2017-06-01', 'yyyy-MM-dd')
    AND gmt_created <= UNIX_TIMESTAMP('2017-08-29', 'yyyy-MM-dd')
GROUP BY FROM_UNIXTIME(gmt_created, 'yyyy-MM-dd')
        ,FROM_UNIXTIME(gmt_created, 'HH')
ORDER BY date_BeiJing
        ,hour_BeiJing
)
SELECT t2.date_BeiJing
        ,t2.hour_BeiJing
        ,t2.order_num AS pay_order_num
        ,t3.order_num AS can_pick_order_num
FROM t2
JOIN t3
ON t2.date_BeiJing = t3.date_BeiJing AND t2.hour_BeiJing = t3.hour_BeiJing
ORDER BY t2.date_BeiJing
        ,t2.hour_BeiJing;




-- 每天付款订单数，可拣货订单数，发货订单数

-- 沙特仓每天客户下单订单数
WITH t1 AS
(SELECT *
        ,(CASE WHEN prepare_pay_time = 0 THEN pay_time ELSE prepare_pay_time END) AS real_pay_time
FROM jolly.who_order_info
WHERE depot_id = 7
     AND order_status = 1
     AND pay_status IN (1, 3)
),
t2 AS
(SELECT FROM_UNIXTIME(real_pay_time, 'yyyy-MM-dd') AS date_BeiJing
        ,COUNT(order_id) AS order_num
FROM t1
WHERE real_pay_time >= UNIX_TIMESTAMP('2017-08-01', 'yyyy-MM-dd')
    AND real_pay_time <= UNIX_TIMESTAMP('2017-09-04', 'yyyy-MM-dd')
GROUP BY FROM_UNIXTIME(real_pay_time, 'yyyy-MM-dd')
ORDER BY date_BeiJing
),

-- 沙特仓每天配货完成订单数（可拣货）
t3 AS
(SELECT FROM_UNIXTIME(gmt_created, 'yyyy-MM-dd') AS date_BeiJing
        ,COUNT(DISTINCT order_id) AS order_num
FROM jolly_wms.who_wms_outing_stock_detail
WHERE depot_id = 7
    AND gmt_created >= UNIX_TIMESTAMP('2017-08-01', 'yyyy-MM-dd')
    AND gmt_created <= UNIX_TIMESTAMP('2017-09-04', 'yyyy-MM-dd')
GROUP BY FROM_UNIXTIME(gmt_created, 'yyyy-MM-dd')
ORDER BY date_BeiJing
)
SELECT t2.date_BeiJing
        ,t2.order_num AS pay_order_num
        ,t3.order_num AS can_pick_order_num
FROM t2
LEFT JOIN t3
            ON t2.date_BeiJing = t3.date_BeiJing
ORDER BY t2.date_BeiJing;




-- =====================================================================================
-- 上架开始和结束时间
WITH t AS
(SELECT  b.depot_id
        ,b.pur_order_sn
        ,b.order_id
        ,b.goods_id
        ,b.sku_id
        ,finish_check_time
        ,on_shelf_finish_time
        ,on_shelf_num
        ,shipping_time
        ,(UNIX_TIMESTAMP(on_shelf_finish_time) - UNIX_TIMESTAMP(finish_check_time)) AS onshelf_duration
FROM zydb.dw_order_sub_order_fact a
LEFT JOIN zydb.dw_demAND_pur b
ON a.order_id=b.order_id
LEFT JOIN zydb.dw_delivered_onself_info c
ON b.pur_order_sn=c.delivered_order_sn
AND b.sku_id=c.sku_id
WHERE shipping_time>='2017-09-01'
AND shipping_time<'2017-09-25'
AND on_shelf_finish_time IS NOT NULL
AND finish_check_time IS NOT NULL
)

-- 每天上架结束时间比质检结束时间早的商品数
SELECT TO_DATE(shipping_time) AS ship_date
        ,SUM(CASE WHEN onshelf_duration < 0 THEN 1 ELSE 0 END) AS less_num
        ,COUNT(1) AS total_num
FROM t
GROUP BY TO_DATE(shipping_time)
ORDER BY ship_date;

-- 上架时间为负数的分布
SELECT floor(onshelf_duration / 3600) AS on_shelf_hour
        ,COUNT(*) AS num
FROM t
WHERE onshelf_duration <= 0
GROUP BY floor(onshelf_duration / 3600)
ORDER BY on_shelf_hour;




--- 7月大陆仓作业时长
SELECT depot_id
    ,avg(receipt_quality_duration + quality_onshelf_duration + picking_duration + package_duration + shipping_duration) AS LT2
FROM zydb.rpt_depot_daily_report
WHERE depot_id IN (4, 5)
 AND data_date >= '2017-07-01'
 AND data_date <= '2017-07-31'
GROUP BY depot_id;


-- HK仓出库明细 impala ==========================================================
SELECT order_sn
        ,pay_time AS 付款时间
        ,no_problems_order_uptime AS 标非时间
        ,outing_stock_time AS 可拣货时间
        ,picking_finish_time AS 拣货完成时间
        ,order_pack_time AS 打包完成时间
        ,shipping_time AS 发运时间
FROM dw.dw_order_node_time
WHERE depot_id = 6
AND is_shiped = 1
AND is_problems_order IN (0, 2)
AND order_status = 1
AND pay_status IN (1, 3)
AND shipping_time >= '2018-01-01'
AND shipping_time < '2018-01-08'
ORDER BY shipping_time;


-- HK仓出库明细 hive推送 ========================================================
SELECT order_sn
        ,pay_time
        ,no_problems_order_uptime
        ,outing_stock_time
        ,picking_finish_time
        ,order_pack_time
        ,shipping_time
FROM zydb.dw_order_node_time
WHERE depot_id = 6
  AND is_shiped = 1
  AND is_problems_order IN (0, 2)
  AND order_status = 1
  AND pay_status IN (1, 3)
  AND shipping_time >= TO_DATE(DATE_SUB(CURRENT_TIMESTAMP(), 7))
  AND shipping_time < TO_DATE(DATE_SUB(CURRENT_TIMESTAMP(), 0))
ORDER BY shipping_time
;


-- 寿元，对比2万个商品的销售

WITH
-- 订单和商品明细
t1 AS
(SELECT p1.order_id
        ,p1.pay_time
        ,TO_DATE(CAST(p1.pay_time AS STRING)) AS pay_date
        ,SUBSTR(CAST(p1.pay_time AS STRING), 12, 2) AS pay_hour
        ,p2.goods_id
        ,SUM(p2.original_goods_number) AS org_goods_num
        ,SUM(p2.original_goods_number * p2.goods_price) AS org_goods_amount
FROM zydb.dw_order_node_time p1
LEFT JOIN jolly.who_order_goods p2 ON p1.order_id = p2.order_id
WHERE p1.pay_time >= FROM_UNIXTIME(UNIX_TIMESTAMP('2017-09-29'))
     AND p1.pay_time < FROM_UNIXTIME(UNIX_TIMESTAMP('2017-10-01'))
     AND p1.pay_status IN (1, 3)
     -- AND p1.order_status = 1
GROUP BY p1.order_id
        ,p1.pay_time
        ,TO_DATE(CAST(p1.pay_time AS STRING))
        ,SUBSTR(CAST(p1.pay_time AS STRING), 12, 2)
        ,p2.goods_id
),
t2 AS
(SELECT goods_id
        ,pay_date
        ,pay_hour
        ,COUNT(order_id ) AS order_num
        ,SUM(org_goods_num) AS org_goods_num
        ,SUM(org_goods_amount) AS org_goods_amount
FROM t1
GROUP BY goods_id
        ,pay_date
        ,pay_hour
)
SELECT *
FROM t2;






SELECT *
FROM t2
LIMIT 10;
ORDER BY goods_id
        ,pay_date
        ,pay_hour;






SELECT pay_date
        ,COUNT(DISTINCT goods_id)
        ,SUM(org_goods_num)
        ,SUM(org_goods_amount)
FROM t2
GROUP BY pay_date;


-- 检查who_order_info表和who_order_shipping_tracking表的订单状态
SELECT p1.pay_id
        ,p1.cod_check_status
        ,p2.shipping_state
        ,COUNT(p1.order_id)
FROM jolly.who_order_info p1
             ,jolly.who_order_shipping_tracking p2
WHERE p1.order_id = p2.order_id
GROUP BY p1.pay_id
        ,p1.cod_check_status
        ,p2.shipping_state
ORDER BY p1.pay_id
        ,p1.cod_check_status
        ,p2.shipping_state;



-- =============================================== 上架相关数据（顶） ===================================================
/*
上架相关数据库表
-- 上架单表：jolly.who_wms_on_shelf_info（只有2017-08-13及以后的数据） -- 2017-08-13以前的数据，用jolly.who_wms_pur_deliver_info表查询
-- 上架商品表：jolly.who_wms_on_shelf_goods
 */

-- 上架单表：jolly.who_wms_on_shelf_info
-- gmt_created：创建时间
-- status：上架单状态：1-待上架,2-上架中,3-上架完成
-- source_type：来源类型：1-批发订单作业单,2-普通采购单(非供应商备货的),3-调拨入库单,4-供应商备货采购单
SELECT *
FROM jolly.who_wms_on_shelf_info
LIMIT 10;

-- 老上架单表：jolly.who_wms_pur_deliver_info
-- deliver_sn：上架单号
-- gmt_created：上架单创建时间
-- status：上架单状态：1-待上架,2-上架中,3-上架完成
-- user_id：猜测是上架员ID
-- finish_time：上架完成时间
-- FROM_type：来源类型：1-批发订单作业单,2-普通采购单(非供应商备货的),3-调拨入库单,4-供应商备货采购单
SELECT *
FROM jolly.who_wms_pur_deliver_info
LIMIT 10;

SELECT depot_id
        ,FROM_UNIXTIME(gmt_created, 'yyyy-MM-dd') AS 创建日期
        ,status
        ,(CASE WHEN status = 1 THEN '待上架'
                      WHEN status = 2 THEN '上架中'
                      WHEN status = 3 THEN '上架完成'
                      ELSE '其他' END) AS 上架状态
        ,COUNT(on_shelf_sn) AS 上架单数量
        ,SUM(total_num) AS 上架商品数量
FROM jolly.who_wms_on_shelf_info
WHERE gmt_created >= UNIX_TIMESTAMP('2017-10-16')
     AND gmt_created < UNIX_TIMESTAMP('2017-10-17')
GROUP BY depot_id
        ,FROM_UNIXTIME(gmt_created, 'yyyy-MM-dd')
        ,status
        ,(CASE WHEN status = 1 THEN '待上架'
                      WHEN status = 2 THEN '上架中'
                      WHEN status = 3 THEN '上架完成'
                      ELSE '其他' END)
ORDER BY depot_id
        ,FROM_UNIXTIME(gmt_created, 'yyyy-MM-dd')
        ,status;


-- 查询昨天及以前生成的，当前仍未完成上架的上架单
-- 1.汇总上架单数和上架商品数量
SELECT depot_id
        ,(CASE WHEN status = 1 THEN '待上架'
                      WHEN status = 2 THEN '上架中'
                      WHEN status = 3 THEN '上架完成'
                      ELSE '其他' END) AS 上架状态
        ,COUNT(on_shelf_sn) AS 上架单数量
        ,SUM(total_num) AS 上架商品数量
FROM jolly.who_wms_on_shelf_info
WHERE gmt_created <= UNIX_TIMESTAMP(DATE_SUB(FROM_UNIXTIME(UNIX_TIMESTAMP('$[&data_date]', 'yyyyMMdd')), 0))
     AND (status = 1 OR status  = 2)    -- 1/2：待上架和上架中
GROUP BY depot_id
        ,(CASE WHEN status = 1 THEN '待上架'
                      WHEN status = 2 THEN '上架中'
                      WHEN status = 3 THEN '上架完成'
                      ELSE '其他' END)
ORDER BY depot_id;
-- 2.上架单list
SELECT p1.on_shelf_sn
        ,p1.depot_id
        ,FROM_UNIXTIME(p1.gmt_created) AS 创建时间
        ,(CASE WHEN p1.status = 1 THEN '待上架'
                      WHEN p1.status = 2 THEN '上架中'
                      WHEN p1.status = 3 THEN '上架完成'
                      ELSE '其他' END) AS 上架状态
        ,(CASE WHEN p1.source_type = 1 THEN '批发订单作业单'
                      WHEN p1.source_type = 2 THEN '普通采购单(非供应商备货)'
                      WHEN p1.source_type = 3 THEN '调拨入库单'
                      WHEN p1.source_type = 4 THEN '供应商备货采购单'
                      ELSE '其他' END) AS 来源类型
        ,p1.on_shelf_admin_id AS 上架员ID
        ,p2.user_name
        ,p1.total_num
FROM jolly.who_wms_on_shelf_info p1
LEFT JOIN jolly.who_rbac_user p2 ON p2.user_id = p1.on_shelf_admin_id
WHERE p1.gmt_created <= UNIX_TIMESTAMP(DATE_SUB(FROM_UNIXTIME(UNIX_TIMESTAMP('$[&data_date]', 'yyyyMMdd')), 0))    -- 0/1/2/3...:设置几天前，0表示昨天生成的上架单
     AND (p1.status = 1 OR status  = 2)    -- 1/2：待上架和上架中
ORDER BY p1.depot_id;


WITH
-- 四仓每天每人完成上架单数量, 商品数量, 上架时长（用于求平均上架时长）
t1 AS
(SELECT FROM_UNIXTIME(p1.on_shelf_finish_time, 'yyyy-MM-dd') AS onshelf_finish_date
        ,p1.depot_id
        ,p1.on_shelf_admin_id AS onshelf_staff_id
        ,p2.user_name AS onshelf_staff_name
        ,COUNT(p1.on_shelf_sn) AS onshelf_order_num
        ,SUM(p1.total_num) AS onshelf_goods_num
        ,SUM((p1.on_shelf_finish_time - p1.gmt_created) / 3600) AS onshelf_hours
FROM jolly.who_wms_on_shelf_info p1
LEFT JOIN jolly.who_rbac_user p2
             ON p1.on_shelf_admin_id = p2.user_id
WHERE p1.status = 3    -- 完成上架
     AND p1.on_shelf_finish_time >= UNIX_TIMESTAMP('2017-04-01')
GROUP BY FROM_UNIXTIME(p1.on_shelf_finish_time, 'yyyy-MM-dd')
        ,p1.depot_id
        ,p1.on_shelf_admin_id
        ,p2.user_name
)

SELECT *
FROM t1
ORDER BY onshelf_finish_date
        ,depot_id
        ,onshelf_staff_id;




-- =============================================== 上架相关数据（底） ===================================================



-- 后台登录用户表（登录执御的各个系统的用户列表）
-- jolly.who_rbac_user
SELECT *
FROM jolly.who_rbac_user
LIMIT 10;



-- ============================================== 调拨单相关数据（顶） ===================================================
/*
-- 说明：调拨单相关数据
-- 作者：Neo王政鸣
-- 更新时间：2017-10-19
 */

-- 调拨单表：jolly.who_wms_allocate_order_info
-- 问题：表中的arrive_time：到货时间是指什么时间？
SELECT *
FROM jolly.who_wms_allocate_order_info
LIMIT 10;

-- 到货单签收表：
-- jolly.who_wms_pur_deliver_receipt  物流单号与采购单/调拨单是一对多关系
-- zydb.ods_wms_pur_deliver_receipt  物流单号与采购单/调拨单是一对一关系
-- 表中的gmt_created是签收时间；

-- 调拨单时间节点表：zydb.dw_allocate_out_node


-- 查询调拨单的签收时间
WITH t1 AS
(SELECT p1.allocate_order_sn
        ,p1.FROM_depot_id
        ,p1.to_depot_id
        ,FROM_UNIXTIME(p1.gmt_created) AS 调拨单创建时间
        ,FROM_UNIXTIME(p1.off_shelf_time) AS 下架时间
        ,FROM_UNIXTIME(p1.finish_packing_time) AS 打包完成时间
        ,FROM_UNIXTIME(p1.out_time) AS 调出仓出库时间
        ,FROM_UNIXTIME(p1.arrive_time) AS 到达调入仓时间
        ,FROM_UNIXTIME(p2.gmt_created) AS receive_time
FROM jolly.who_wms_allocate_order_info p1
LEFT JOIN zydb.ods_wms_pur_deliver_receipt p2
             ON p1.allocate_order_sn = p2.pur_order_sn
WHERE p1.gmt_created >= UNIX_TIMESTAMP('2017-01-01')
--     AND p1.gmt_created < UNIX_TIMESTAMP('2017-10-09')
)
-- 查询明细
SELECT *
FROM t1
WHERE receive_time IS NOT NULL
LIMIT 10;
-- 查询有多少调拨单没有签收时间
SELECT to_depot_id
        ,COUNT(allocate_order_sn) AS total_num
        ,COUNT(CASE WHEN receive_time IS NULL THEN 1 ELSE NULL END) AS no_receive_time_num
FROM t1
GROUP BY to_depot_id
ORDER BY to_depot_id;



-- ============================================== 调拨单相关数据（底） ===================================================




-- ============================================== 仓库作业环节相关数据（顶） ===================================================

-- 1.到货签收

-- 1.1 到货签收单 jolly.who_wms_delivered_receipt_info

-- 1.2 到货单表 jolly.who_wms_delivered_order_info

-- 1.3 到货单详情表 jolly.who_wms_delivered_order_goods

-- 1.4 采购单到货表 jolly.who_wms_pur_deliver_receipt

-- 1.5 采购单商品表 jolly.who_wms_pur_deliver_goods


-- 2.质检









-- ============================================== 仓库作业环节相关数据（底） ===================================================

-- zydb.dw_goods_on_sale
-- 在售商品每天的售价: prst_price








-- zydb.ods_who_wms_goods_stock_total_detail & zydb.ods_who_wms_goods_stock_detail

SELECT data_date
        ,COUNT(1)
FROM zydb.ods_who_wms_goods_stock_total_detail
GROUP BY data_date
ORDER BY data_date
;


SELECT *
FROM jolly_tms_center.tms_order_info
WHERE shipped_time >0
LIMIT 10
;


with t1 AS
(SELECT p1.customer_order_id
        ,COUNT(1) AS num
FROM jolly_tms_center.tms_order_info p1
GROUP BY p1.customer_order_id
)
SELECT customer_order_id
        ,num
FROM t1
ORDER BY num desc
LIMIT 10;




SELECT tms_order_id
        ,customer_order_id
        ,tracking_no
        ,shipping_status
        ,depot_id
        ,FROM_UNIXTIME(shipped_time) AS shipping_time
        ,FROM_UNIXTIME(gmt_modified) AS gmt_modified
FROM jolly_tms_center.tms_order_info
WHERE customer_order_id = 25181391
;


SELECT *
FROM jolly.who_order_info
WHERE order_id  = 25892073
;




-- 检查订单的shipping_status vs cod_check_status
WITH t1 AS
(SELECT p1.customer_order_id
        ,p2.order_sn
        ,p1.shipping_status
        ,p2.cod_check_status
FROM jolly_tms_center.tms_order_info p1
LEFT JOIN jolly.who_order_info p2
on p1.customer_order_id = p2.order_id
WHERE p1.shipped_time > 0
)
-- 各状态对应的订单数
SELECT shipping_status
        ,cod_check_status
        ,COUNT(customer_order_id) AS order_num
FROM t1
GROUP BY shipping_status
        ,cod_check_status;
-- 核查两个状态异常的订单
SELECT *
FROM t1
WHERE cod_check_status = 0
     AND shipping_status = 3
LIMIT 5;


-- tms_order_info
SELECT *
FROM jolly_tms_center.tms_order_info p1
LIMIT 10;


SELECT *
        ,FROM_UNIXTIME(gmt_created)
FROM jolly.who_wms_on_shelf_goods_price
WHERE delivered_order_sn = 'GZ2DB171022092806186Y94IF'
LIMIT 10;


SELECT *
FROM jolly.who_wms_on_shelf_info
LIMIT 10;

SELECT *
FROM zydb.dw_goods_on_sale
WHERE goods_id = 374404
LIMIT 10;



-- HK仓每天发运订单数和商品数
SELECT SUBSTR(shipping_time, 1, 10) AS ship_date
        ,COUNT(DISTINCT order_sn) AS order_num
        ,SUM(goods_number) AS goods_num
FROM zydb.dw_order_node_time p1
WHERE p1.depot_id = 6
     AND p1.is_shiped = 1
     AND p1.order_status = 1
     AND p1.pay_status IN (1, 3)
GROUP BY SUBSTR(shipping_time, 1, 10)
ORDER BY ship_date;

-- HK仓每天库存总量
SELECT data_date
        ,SUM(total_stock_num) AS total_stock_num
FROM zydb.ods_who_wms_goods_stock_total_detail_aws
WHERE depot_id = 6
GROUP BY data_date
ORDER BY data_date;


-- 11天销售数量，用前10天销售额预测当天销售数量
WITH t1 AS
(SELECT SUBSTR(p1.pay_time, 1, 10) AS pay_date
        ,p2.sku_id
        ,SUM(p2.goods_number) AS sales
FROM zydb.dw_order_node_time p1
LEFT JOIN jolly.who_order_goods p2 ON p1.order_id = p2.order_id
WHERE p1.pay_time >= '2017-10-01'
     AND p1.pay_time < '2017-10-12'
GROUP BY SUBSTR(p1.pay_time, 1, 10)
        ,p2.sku_id
)

SELECT *
FROM t1;





-- 特定sku销量
WITH t1 AS
(SELECT p1.sku_id
        ,p2.depot_id
        ,SUM(CASE WHEN p2.pay_time < '2017-10-20' THEN p1.goods_number ELSE NULL END) AS sales_num_19
        ,SUM(CASE WHEN p2.pay_time >= '2017-10-20' THEN p1.goods_number ELSE NULL END) AS sales_num_26
FROM jolly.who_order_goods p1
RIGHT JOIN zydb.dw_order_node_time p2 ON p1.order_id = p2.order_id
WHERE p2.pay_time >= '2017-10-12'
     AND p2.pay_time < '2017-10-27'
GROUP BY p1.sku_id
        ,p2.depot_id
)
SELECT *
FROM t1
WHERE sku_id IN ()
;







SELECT *
FROM jolly.who_wms_goods_stock_detail_log
WHERE depot_id IN (4, 5, 6)
AND change_type = 12
AND change_time >= UNIX_TIMESTAMP()
LIMIT 10;


-- 东莞仓每月订单内商品数量的分布
SELECT SUBSTR(shipping_time, 1, 7) AS month
        ,(CASE WHEN goods_number <= 4 THEN '<=4件'
                      WHEN goods_number <= 8 THEN '5-8件'
                      WHEN goods_number >=9 THEN '>=9件'
                      ELSE '其他' END) AS goods_num_clASs
        ,COUNT(order_sn) AS order_num
FROM zydb.dw_order_node_time
WHERE depot_id = 4
     AND goods_number >=1
GROUP BY SUBSTR(shipping_time, 1, 7)
        ,(CASE WHEN goods_number <= 4 THEN '<=4件'
                      WHEN goods_number <= 8 THEN '5-8件'
                      WHEN goods_number >=9 THEN '>=9件'
                      ELSE '其他' END)
;


-- 新仓库日报，提货订单数

SELECT depod_id depot_id,COUNT(*) pickup_orders FROM
    zydb.dw_order_shipping_tracking_node a
    LEFT JOIN
    zydb.dw_order_sub_order_fact b
    ON a.order_id=b.order_id
    WHERE lading_time>=FROM_UNIXTIME(UNIX_TIMESTAMP('${data_date}','yyyyMMdd'))
    AND lading_time<date_add(FROM_UNIXTIME(UNIX_TIMESTAMP('${data_date}','yyyyMMdd')),1)
    GROUP BY depod_id

-- 根据 jolly.who_wms_lading_order
WITH t1 AS
(SELECT p1.lading_sn
        ,p1.depot_id
        ,FROM_UNIXTIME(p1.create_time, 'yyyy-MM-dd') AS create_date
        ,FROM_UNIXTIME(p1.create_time) AS create_time
        ,FROM_UNIXTIME(p1.operate_time, 'yyyy-MM-dd') AS operate_date
        ,FROM_UNIXTIME(p1.operate_time) AS operate_time
        ,COUNT(p2.order_sn) AS order_num
FROM jolly.who_wms_lading_order p1
LEFT JOIN jolly.who_wms_lading_order_detail p2
             ON p1.id = p2.lading_order_id
WHERE p1.operate_time >= UNIX_TIMESTAMP('2017-11-01', 'yyyy-MM-dd')
     AND p1.operate_time < UNIX_TIMESTAMP('2017-11-08', 'yyyy-MM-dd')
     AND p1.lading_status = 2
GROUP BY p1.lading_sn
        ,p1.depot_id
        ,FROM_UNIXTIME(p1.create_time, 'yyyy-MM-dd')
        ,FROM_UNIXTIME(p1.create_time)
        ,FROM_UNIXTIME(p1.operate_time, 'yyyy-MM-dd')
        ,FROM_UNIXTIME(p1.operate_time)
)
SELECT operate_date
        ,create_date
        ,depot_id
        ,SUM(order_num) AS order_num
FROM t1
WHERE depot_id = 4
GROUP BY operate_date
        ,create_date
        ,depot_id
;

-- 印度尼西亚订单中商品数量的分布
-- jolly.who_region, region_id = 1788, region_name = 'Indonesia'
-- 指导改善订单包裹大小
WITH t1 AS
(SELECT p2.goods_num AS total_goods_num
        ,p3.cat_level1_name
        ,p3.cat_level2_name
        ,(CASE WHEN p5.region_id = 1788 THEN 'Indonesia' ELSE 'Others' END) AS COUNTry
        ,COUNT(DISTINCT p2.order_sn) AS order_num
        ,SUM(p1.goods_number) AS goods_num
FROM jolly.who_order_info p2
LEFT JOIN jolly.who_order_goods p1
             ON p1.order_id = p2.order_id
LEFT JOIN zydb.dim_jc_goods p3
             ON p3.goods_id = p1.goods_id
LEFT JOIN jolly.who_order_user_info p4
             ON p2.order_id = p4.order_id
          --AND p4.COUNTry = 1788
LEFT JOIN jolly.who_region p5
             ON p4.COUNTry = p5.region_id AND p5.region_type = 0 AND p5.region_status = 1
WHERE p5.region_id IS NOT NULL
     AND P2.shipping_time >= UNIX_TIMESTAMP('2017-08-01')
     AND P2.shipping_time < UNIX_TIMESTAMP('2017-11-01')
     AND p2.goods_num <=5
     AND p2.goods_num >=1
     AND p2.order_status = 1
     AND p2.is_shiped = 1
GROUP BY p2.goods_num
        ,p3.cat_level1_name
        ,p3.cat_level2_name
        ,(CASE WHEN p5.region_id = 1788 THEN 'Indonesia' ELSE 'Others' END)
)
SELECT *
FROM t1;





SELECT *
FROM zydb.dw_delivered_order_info
WHERE start_onself_time >= '2017-11-01'
LIMIT 100;

SELECT *
FROM zydb.dw_delivered_receipt_onself p1
WHERE p1.delivered_order_sn = 'GZ2FHD201711071801481083'
;

SELECT pur_order_sn
        ,goods_id
        ,FROM_UNIXTIME(gmt_created)
FROM jolly.who_wms_pur_deliver_goods
WHERE pur_order_sn = 'GZ2FHD201711071801481083'
;

SELECT FROM_UNIXTIME(max(gmt_created))
FROM zydb.ods_wms_pur_deliver_receipt
--WHERE pur_order_sn = 'GZ2FHD201711071801481083'
;

SELECT FROM_UNIXTIME(gmt_created)
        ,pur_order_sn
FROM jolly.who_wms_pur_deliver_receipt
WHERE pur_order_sn = 'GZ2FHD201711071801481083'
;



WITH t1 AS
(SELECT p1.depot_id
        ,p1.delivered_order_sn
        ,P1.goods_id
        ,p1.goods_sn
        ,SUM(p1.delivered_num) AS 签收商品数量
        ,SUM(p1.checked_num) AS 质检商品数量
        ,SUM(p1.exp_num) AS 异常商品数量
        ,MIN(p1.start_receipt_time) AS 质检开始时间
        ,MAX(p1.finish_check_time) AS 质检结束时间
FROM zydb.dw_delivered_receipt_onself p1
WHERE p1.depot_id IN (4, 5, 6, 7)
GROUP BY p1.depot_id
        ,p1.delivered_order_sn
        ,P1.goods_id
        ,p1.goods_sn
)
SELECT depot_id
        ,SUM(质检商品数量)
FROM t1
WHERE 质检结束时间 >= '2017-11-09'
     AND 质检结束时间 < '2017-11-10'
GROUP BY depot_id
ORDER BY depot_id;


-- ?????????????&???????
WITH
-- GZ2 + DG1 + HK
t1 AS
(SELECT p1.depot_id
        ,FROM_UNIXTIME(p1.change_time, 'yyyy-MM-dd') AS data_date
        ,SUM(CASE WHEN p1.change_type = 5 THEN p1.change_num ELSE 0 END) AS whout_num
        ,SUM(CASE WHEN p1.change_type = 3 THEN p1.change_num ELSE 0 END) AS return_num
FROM jolly.who_wms_goods_stock_detail_log p1
WHERE p1.depot_id IN (4, 5, 6)
     AND p1.change_time >= UNIX_TIMESTAMP('2017-08-01')
GROUP BY p1.depot_id
        ,FROM_UNIXTIME(p1.change_time, 'yyyy-MM-dd')
),
-- SA
t2 AS
(SELECT p1.depot_id
        ,FROM_UNIXTIME(p1.change_time, 'yyyy-MM-dd') AS data_date
        ,SUM(CASE WHEN p1.change_type = 5 THEN p1.change_num ELSE 0 END) AS whout_num
        ,SUM(CASE WHEN p1.change_type = 3 THEN p1.change_num ELSE 0 END) AS return_num
FROM jolly_wms.who_wms_goods_stock_detail_log p1
WHERE p1.depot_id = 7
     AND p1.change_time >= UNIX_TIMESTAMP('2017-08-01')
GROUP BY p1.depot_id
        ,FROM_UNIXTIME(p1.change_time, 'yyyy-MM-dd')
),
-- UNION
t3 AS
(SELECT * FROM t1
UNION ALL
SELECT * FROM t2
)
SELECT *
FROM t3
LIMIT 10;

-- ÿ??????
-- zydb.dw_order_sub_order_fact
SELECT p1.depod_id AS depot_id
        ,SUBSTR(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END, 1, 10) AS data_date
        ,SUM(p1.goods_number) AS sale_num
FROM zydb.dw_order_sub_order_fact p1
WHERE p1.depod_id IN (4, 5, 6, 7)
     AND p1.order_status = 1
     AND p1.pay_status IN (1, 3)
     AND (CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END) >= '2017-08-01'
GROUP BY p1.depod_id
        ,SUBSTR(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END, 1, 10)
;
-- jolly.who_order_info
WITH t1 AS
(SELECT p1.*
        ,decode(prepare_pay_time = 0, pay_time, prepare_pay_time) AS real_pay_time
FROM jolly.who_order_info p1
WHERE p1.order_status = 1
    AND p1.pay_status IN (1, 3)
)
SELECT FROM_UNIXTIME(real_pay_time, 'yyyy-MM-dd') AS real_pay_date
        ,SUM(goods_num) AS goods_num
FROM t1
WHERE t1.real_pay_time >= UNIX_TIMESTAMP('2017-04-01')
GROUP BY FROM_UNIXTIME(real_pay_time, 'yyyy-MM-dd')
ORDER BY real_pay_date
;


-- ÿ?ǩ????
SELECT FROM_UNIXTIME(p1.update_time, 'yyyy-MM-dd') AS data_date
        ,SUM(p2.goods_number) AS receive_num
FROM jolly.who_order_shipping_tracking p1
LEFT JOIN zydb.dw_order_sub_order_fact p2
             ON p1.order_id = p2.order_id
          AND p1.update_time > UNIX_TIMESTAMP(p2.shipping_time)
WHERE p1.shipping_state=3
     AND p1.update_time >= UNIX_TIMESTAMP('2017-08-01')
     AND p1.update_time < UNIX_TIMESTAMP(TO_DATE(NOW()))
GROUP BY FROM_UNIXTIME(p1.update_time, 'yyyy-MM-dd')
LIMIT 10;


SELECT *
FROM jolly.who_wms_picking_exception_detail p1
WHERE p1.order_sn = 'JIDA17111007585307397440'
;

JARI17103012321379095901

SELECT *
FROM jolly.who_wms_returned_order_info p1
WHERE p1.returned_order_sn = 'JIDA17111007585307397440'
;


SELECT *
FROM jolly.who_pur_set_value
WHERE value_id = 24
;



-- 订单取消时长分布
WITH t1 AS
(SELECT p1.returned_order_id
        ,p1.returned_order_sn
        ,FROM_UNIXTIME(p1.returned_time) AS returned_time
        ,p2.pay_time
        ,p2.outing_stock_time
        ,p2.shipping_time
        ,CEILING((p1.returned_time - UNIX_TIMESTAMP(p2.pay_time))/3600) AS pay_to_return
        ,CEILING((p1.returned_time - UNIX_TIMESTAMP(p2.outing_stock_time))/3600) AS pay_to_outing_stock
        ,p2.is_shiped
        ,(CASE WHEN is_shiped IN (0, 4, 5) THEN 'pay_not_prepare' ELSE 'prepare_not_ship' END) AS status
FROM jolly.who_wms_returned_order_info p1
LEFT JOIN zydb.dw_order_node_time p2
             ON p1.returned_order_id = p2.order_id
WHERE p1.returned_time >= UNIX_TIMESTAMP('2017-11-16')
     AND p1.returned_time < UNIX_TIMESTAMP('2017-11-23')
     AND p2.is_shiped NOT IN (1, 2)
)
-- is_shiped IN (3, 6, 7, 8)  已配货未出库
-- is_shiped IN (0, 4, 5)  已支付未配货

SELECT *
FROM t1
WHERE is_shiped = 7
LIMIT 10;

-- 分组汇总
SELECT pay_to_return
        --,status
        ,COUNT(returned_order_sn) AS order_num
FROM t1
GROUP BY pay_to_return
        --,status
;


-- 商品上架量与配货量的关系
-- 00:00:00 — 01:00:00：上架X1件商品，配货Y1件商品， 配货Z1个订单
-- 01:00:00 — 02:00:00：上架X2件商品，配货Y2件商品， 配货Z2个订单
-- 。。。。。。

WITH
-- 1.上架商品数
t1 AS
(SELECT p1.depot_id
        ,SUBSTR(p1.on_shelf_finish_time, 1, 10) AS onshelf_date
        ,SUBSTR(p1.on_shelf_finish_time, 12, 2) AS onshelf_hour
        ,SUM(p1.on_shelf_num) AS onshelf_num
FROM zydb.dw_delivered_receipt_onself p1
WHERE p1.on_shelf_finish_time >= '2017-10-01'
     AND p1.on_shelf_finish_time < '2017-11-24'
GROUP BY p1.depot_id
        ,SUBSTR(p1.on_shelf_finish_time, 1, 10)
        ,SUBSTR(p1.on_shelf_finish_time, 12, 2)
),
-- 2.完成配货商品数和订单数
t2 AS
(SELECT p1.depot_id
        ,SUBSTR(p1.outing_stock_time, 1, 10) AS outing_stock_date
        ,SUBSTR(p1.outing_stock_time, 12, 2) AS outing_stock_hour
        ,COUNT(p1.order_sn) AS order_num
        ,SUM(goods_number) AS goods_num
FROM zydb.dw_order_node_time p1
WHERE p1.is_shiped IN (1, 3, 6, 7, 8)
     AND p1.outing_stock_time >= '2017-10-01'
GROUP BY p1.depot_id
        ,SUBSTR(p1.outing_stock_time, 1, 10)
        ,SUBSTR(p1.outing_stock_time, 12, 2)
)

SELECT t1.*
        ,t2.order_num
        ,t2.goods_num
FROM t1
LEFT JOIN t2
             ON t1.depot_id = t2.depot_id
          AND t1.onshelf_date = t2.outing_stock_date
          AND t1.onshelf_hour = t2.outing_stock_hour
ORDER BY t1.depot_id
        ,t1.onshelf_date
        ,t1.onshelf_hour
;


-- HK仓独有库存的商品在印尼市场的下单情况
-- 供应商与发货仓库对应表：jolly.who_esoloo_supplier_send_depot
-- 商品发货仓库对应表：jolly.who_goods_send_depot

WITH
-- 会发货到HK仓的供应商代码
t1 AS
(SELECT supp_id
        ,supp_code
FROM jolly.who_esoloo_supplier_send_depot
WHERE depot_id = 6
GROUP BY supp_id
        ,supp_code
),
-- 供应商发货给几个仓库
t2 AS
(SELECT supp_id
        ,supp_code
        ,COUNT(depot_id) AS depot_num
FROM jolly.who_esoloo_supplier_send_depot
GROUP BY supp_id
        ,supp_code
),
-- 只发货给HK仓的供应商
t3 AS
(SELECT t1.*
FROM t1
INNER JOIN t2
                 ON t1.supp_id = t2.supp_id
WHERE t2.depot_num = 1
),
-- HK仓独有库存商品列表
t4 AS
(SELECT p1.goods_id
        ,p1.goods_sn
        ,p1.is_on_sale
        ,p1.shop_price
        ,p1.provide_code AS supp_code
        ,p1.supp_name
FROM zydb.dim_jc_goods AS p1, t3
WHERE p1.provide_code = t3.supp_code
),
-- goods_id在印尼的下单量
t5 AS
(SELECT p1.goods_id
        ,COUNT(DISTINCT p2.order_id) AS order_num           -- 下单订单数
        ,SUM(p1.original_goods_number) AS org_goods_num             -- 下单商品数
FROM zydb.dw_order_sub_order_fact p2
LEFT JOIN jolly.who_order_goods p1
             ON p1.order_id = p2.order_id
LEFT JOIN jolly.who_order_user_info p4
             ON p2.order_id = p4.order_id
LEFT JOIN jolly.who_region p5
             ON p4.COUNTry = p5.region_id AND p5.region_type = 0 AND p5.region_status = 1
WHERE p5.region_id IS NOT NULL
     AND p2.add_time >= '2017-10-01'
     AND p2.add_time < '2017-11-28'
     AND p4.COUNTry = 1788
GROUP BY p1.goods_id
),
-- 最终结果，关联t4/t5
t0 AS
(SELECT t4.*
        ,t5.order_num
        ,t5.org_goods_num
FROM t4
LEFT JOIN t5
             ON t4.goods_id = t5.goods_id
)

SELECT COUNT(*)
FROM t0;
;


WITH
-- 1.系统自动退货的
t1 AS
(SELECT p1.returned_order_id AS order_id
        ,p2.sku_id
        ,'自动退货' AS oos_type
        ,p2.returned_num AS sku_num
FROM jolly_oms.who_oms_apply_returned_order_info p1
LEFT JOIN jolly_oms.who_oms_apply_returned_order_goods p2
             ON p1.returned_rec_id = p2.returned_rec_id
WHERE p1.remark = '===缺货订单，系统自动退货==='
     AND p1.apply_time >= UNIX_TIMESTAMP('2017-11-16')
     AND p1.apply_time < UNIX_TIMESTAMP('2017-12-01')
     AND p1.return_reASon = 10
     AND p2.returned_num >= 1
),


-- ======================================
WITH
-- 2.手工添加异常的
t2 AS
(SELECT p1.order_id
        ,p1.sku_id
        ,(CASE WHEN p1.type IN (1, 2, 3, 9) THEN 'pur'
               WHEN p1.type IN (5, 6, 7, 10, 13) THEN 'wh'
               WHEN p1.type IN (4,  11, 12) THEN 'sys'
               ELSE 'other'
          END) AS oos_type
        ,p1.oos_num
FROM jolly.who_wms_order_oos_log p1
WHERE p1.create_time >= UNIX_TIMESTAMP('2017-11-16')
     AND p1.create_time < UNIX_TIMESTAMP('2017-12-01')
     AND p1.oos_num >= 1
),
-- 关联订单表，商品信息表
t4 AS
(SELECT t2.*
        ,p2.order_sn
        ,(CASE WHEN p2.depod_id = 4 THEN '广州仓'
                      WHEN p2.depod_id IN (5, 14) THEN '东莞仓'
                      WHEN p2.depod_id = 6 THEN '香港仓'
                      WHEN p2.depod_id = 7 THEN '沙特仓'
                      ELSE '其他' END) AS depot_name
        ,p2.original_goods_number
        ,p2.order_amount_no_bonus
        ,(CASE WHEN p2.order_status = 1 THEN '已确认'
                      WHEN p2.order_status = 2 THEN '已取消'
                      WHEN p2.order_status = 3 THEN '已退货'
                      WHEN p2.order_status = 4 THEN '已拆分'
                      ELSE '其他' END) AS order_status
        ,(t2.oos_num * p3.prop_price) AS oos_amount
FROM t2
LEFT JOIN zydb.dw_order_sub_order_fact p2
             ON t2.order_id = p2.order_id
LEFT JOIN jolly.who_sku_relation p3
             ON t2.sku_id = p3.rec_id
),
-- 汇总到订单级别
t5 AS
(SELECT order_id
        ,order_sn
        ,depot_name
        ,original_goods_number
        ,order_amount_no_bonus
        ,order_status
        ,SUM(oos_num) AS oos_num
        ,SUM(CASE WHEN oos_type = 'pur' THEN 1 ELSE 0 END) AS pur_oos_num
        ,SUM(CASE WHEN oos_type = 'wh' THEN 1 ELSE 0 END) AS wh_oos_num
        ,SUM(CASE WHEN oos_type = 'sys' THEN 1 ELSE 0 END) AS sys_oos_num
        ,SUM(CASE WHEN oos_type = 'other' THEN 1 ELSE 0 END) AS other_oos_num
        ,ROUND(SUM(oos_amount), 1) AS oos_amount
        ,ROUND(SUM(CASE WHEN oos_type = 'pur' THEN oos_amount ELSE 0 END), 1) AS pur_oos_amount
        ,ROUND(SUM(CASE WHEN oos_type = 'wh' THEN oos_amount ELSE 0 END), 1) AS wh_oos_amount
        ,ROUND(SUM(CASE WHEN oos_type = 'sys' THEN oos_amount ELSE 0 END), 1) AS sys_oos_amount
        ,ROUND(SUM(CASE WHEN oos_type = 'other' THEN oos_amount ELSE 0 END), 1) AS other_oos_amount
        ,ROUND(SUM(oos_num) / original_goods_number, 3) AS oos_num_prop
        ,ROUND(SUM(oos_amount) / order_amount_no_bonus, 3) AS oos_amount_prop
FROM t4
GROUP BY order_id
        ,order_sn
        ,depot_name
        ,original_goods_number
        ,order_amount_no_bonus
        ,order_status
)

-- 根据缺货商品数量汇总订单数量和金额
SELECT oos_num
        ,COUNT(DISTINCT order_sn) AS order_num
        ,SUM(oos_num) AS oos_num2
        ,SUM(order_amount_no_bonus) AS order_amount_no_bonus
        ,SUM(oos_amount) AS oos_amount
FROM t5
GROUP BY oos_num
ORDER BY oos_num2;


-- 因拣货异常、打包异常缺掉的数量 ======================================================
WITH
-- 2.手工添加异常的
t2 AS
(SELECT p1.order_id
        ,p2.order_sn
        ,p2.original_goods_number
        ,p2.goods_number
        ,p2.pay_time
        ,p2.depot_id
        ,p1.sku_id
        ,p4.supp_name
        ,FROM_UNIXTIME(p1.create_time) AS add_time
        ,(CASE WHEN p1.type = 5 THEN '拣货异常'
                      WHEN p1.type = 13 THEN '打包异常'
                      ELSE '其他' END) AS oos_type
        ,p1.oos_num
FROM jolly.who_wms_order_oos_log p1
LEFT JOIN zydb.dw_order_node_time p2
             ON p1.order_id = p2.order_id
LEFT JOIN zydb.dw_order_goods_fact p3
             ON p1.order_id = p3.order_id AND p1.sku_id = p3.sku_id
LEFT JOIN zydb.dim_jc_goods p4
             ON p3.goods_id = p4.goods_id
WHERE p1.type IN (5, 13)
     AND p1.create_time >= UNIX_TIMESTAMP('2017-11-20')
     AND p1.oos_num >= 1
)

SELECT *
FROM t2
LIMIT 10;



-- 订单缺货日志表 jolly.who_wms_order_oos_log

,(CASE WHEN p1.type = 1 THEN '采购单取消'
       WHEN p1.type = 2 THEN '供应商门户确认缺货'
       WHEN p1.type = 3 THEN '处理到货异常'
       WHEN p1.type = 4 THEN '超期标记缺货'
       WHEN p1.type = 5 THEN '拣货异常'
       WHEN p1.type = 6 THEN '调拨取消'
       WHEN p1.type = 7 THEN '盘亏'
       WHEN p1.type = 9 THEN '采购延迟到货'
       WHEN p1.type = 10 THEN '调拨延迟'
       WHEN p1.type = 11 THEN '超卖'
       WHEN p1.type = 12 THEN 'HK仓超卖'
       WHEN p1.type = 13 THEN '打包异常'
       ELSE '其他'
  END) AS oos_type





-- 一共缺了多少？
SELECT oos_type
        ,COUNT(DISTINCT order_id) AS order_num
        ,SUM(oos_num) AS oos_num
FROM t1
GROUP BY oos_type
;

-- 每天缺多少？
SELECT oos_date
        ,COUNT(DISTINCT order_id) AS order_num
        ,SUM(oos_num) AS oos_num
FROM t1
GROUP BY oos_date
ORDER BY oos_date
;

-- 明细数据
SELECT *
FROM t1
LIMIT 10;


-- 申请退货退款表
-- jolly_oms.who_oms_apply_returned_order_info
-- jolly_oms.who_oms_apply_returned_order_goods


SELECT *
FROM jolly_oms.who_oms_apply_returned_order_info
LIMIT 10;


SELECT *
FROM jolly_oms.who_oms_apply_returned_order_goods
LIMIT 10;




;



SELECT p1.returned_order_id
        ,p1.returned_order_sn
        ,p1.return_reASon
        ,p1.remark
        ,p1.returned_op_type
        ,p1.depot_id
        ,p1.return_status
        ,p1.apply_time
        ,p1.close_reASon
        ,p1.order_goods_num
        ,p1.returned_goods_num
        ,p1.process_status
        ,p2.goods_id
        ,p2.goods_sn
        ,p2.sku_id
        ,p2.returned_num
        ,p2.returned_amount
        ,p2.gmt_created
FROM jolly_oms.who_oms_apply_returned_order_info p1
LEFT JOIN jolly_oms.who_oms_apply_returned_order_goods p2
ON p1.returned_rec_id = p2.returned_rec_id
WHERE p1.remark = '===缺货订单，系统自动退货==='
AND p1.apply_time >= UNIX_TIMESTAMP('2017-11-16')
AND p1.apply_time < UNIX_TIMESTAMP('2017-12-01')
AND p1.return_reASon = 10
LIMIT 10;


/*
jolly.who_region.region_id, region_name
GCC国家的代码和名称：
阿拉伯联合酋长国：1878， United Arab Emirates
沙特阿拉伯：1876，Saudi Arabia
阿曼：1861，Oman
巴林：1877，Bahrain
科威特：1859，Kuwait
卡塔尔：1868，Qatar
 */

-- 每月销售额，销售数量
WITH
t1 AS
(SELECT p5.region_id
        ,p5.region_name
        ,p3.cat_level1_name
        ,COUNT(p1.order_id) AS order_num
        ,SUM(p1.goods_number) AS goods_num
FROM zydb.dw_order_node_time p1
LEFT JOIN zydb.dw_order_goods_fact p2
             ON p1.order_id = p2.order_id
LEFT JOIN zydb.dim_jc_goods p3
             ON p2.goods_id = p3.goods_id
LEFT JOIN jolly.who_order_user_info p4
             ON p1.order_id = p4.order_id
LEFT JOIN jolly.who_region p5
             ON p4.COUNTry = p5.region_id
WHERE p1.order_status = 1
     AND p1.is_shiped = 1
     AND p1.pay_time >= '2017-05-27'
     AND p1.pay_time < '2017-06-26'
     AND p5.region_type = 0
     AND p5.region_status = 1
GROUP BY  p5.region_id
        ,p5.region_name
        ,p3.cat_level1_name
)

SELECT *
FROM t1
WHERE region_id = 1878
;

WITH
-- 2017年类目销售结构
t1 AS
(SELECT p3.cate_level1_name
        --,p3.cate_level2_name
        --,p3.cate_level3_name
        --,p3.cate_level4_name
        ,SUM(p2.goods_number) AS sales_goods_num
FROM zydb.dw_order_node_time p1
INNER JOIN zydb.dw_order_goods_fact p2
        ON p1.order_id = p2.order_id
LEFT JOIN zydb.dim_goods p3
       ON p2.goods_id = p3.goods_id
WHERE p1.order_status = 1
  --AND p1.is_shiped = 1
  --AND p1.depot_id IN (5, 14)
  AND p1.pay_time >= '2017-01-01'
  AND p1.pay_time <  '2018-01-01'
  AND p1.pay_status IN (1, 3)
GROUP BY p3.cate_level1_name
        --,p3.cate_level2_name
        --,p3.cate_level3_name
        --,p3.cate_level4_name
)
SELECT *
FROM t1
ORDER BY sales_goods_num DESC
;

,
-- 当前库存结构
t2 AS
(SELECT p2.cate_level1_name
        ,p2.cate_level2_name
        ,p2.cate_level3_name
        ,p2.cate_level4_name
        ,SUM(p1.stock_num) AS stock_goods_num
FROM zydb.ods_who_wms_goods_stock_detail AS p1
LEFT JOIN zydb.dim_goods AS p2
       ON p1.goods_id = p2.goods_id
WHERE p1.data_date = '20180129'
  AND p1.depot_id IN (5, 14)
GROUP BY p2.cate_level1_name
        ,p2.cate_level2_name
        ,p2.cate_level3_name
        ,p2.cate_level4_name
)
-- full outer join
SELECT COALESCE(t1.cate_level1_name, t2.cate_level1_name) AS cate_level1_name
        ,COALESCE(t1.cate_level2_name, t2.cate_level2_name) AS cate_level2_name
        ,COALESCE(t1.cate_level3_name, t2.cate_level3_name) AS cate_level3_name
        ,COALESCE(t1.cate_level4_name, t2.cate_level4_name) AS cate_level4_name
        ,t1.sales_goods_num
        ,t2.stock_goods_num
FROM t1
FULL OUTER JOIN t2
             ON t1.cate_level1_name = t2.cate_level1_name
            AND t1.cate_level2_name = t2.cate_level2_name
            AND t1.cate_level3_name = t2.cate_level3_name
            AND t1.cate_level4_name = t2.cate_level4_name
;



-- 打包耗材使用比例

-- 打包耗材使用比例
-- 各打包耗材有多少订单使用
SELECT UCASE(p2.material_sn) AS material_sn2
        ,p2.material_name
        ,p3.weight
        ,p3.volume
        ,p3.stANDard
        ,p3.unit_price
        ,(CASE WHEN p3.status = 1 THEN '正常'
                     WHEN p3.status = 2 THEN '禁用'
                     ELSE '其他' END) AS material_status
        ,COUNT(p1.order_id) AS order_num
FROM zydb.dw_order_sub_order_fact p1
INNER JOIN jolly.who_wms_order_package p2
                 ON p1.order_id = p2.order_id
LEFT JOIN jolly.who_wms_material p3
             ON p2.material_sn = p3.material_sn
WHERE p1.order_status = 1
     AND p1.is_shiped = 1
     AND p1.pay_time >= '2017-01-01'
     AND p1.pay_time < '2017-12-01'
GROUP BY UCASE(p2.material_sn)
        ,p2.material_name
        ,p3.weight
        ,p3.volume
        ,p3.stANDard
        ,p3.unit_price
        ,(CASE WHEN p3.status = 1 THEN '正常'
                      WHEN p3.status = 2 THEN '禁用'
                      ELSE '其他' END)
ORDER BY material_sn2
LIMIT 100;


-- 特定invoice_no的发货时间  ===================================================
/*
hive上传文件建临时表步骤：
第一步：建好文件，存csv格式，不需要带表头字段，文件命名一定要为英文，如命名为 kidsfeaturecode.csv；
第二步：将csv格式文件上传至/user/zybiro/load/temp目录下；如上面建的文件，上完之后文件完整的路径应为/user/zybiro/load/temp/kidsfeaturecode.csv；
第三步：运行建表语句，建表；如想要建一个名称为 zybiro.kids_featurecode，里面存featurecode字段，数据类型为string的表，具体语句如下：
create table zybiro.kids_featurecode(featurecode string)
row format delimited fields terminated by '\t'
lines terminated by '\n'
stored AS textfile
第四步： 运行以下语句：
load data INpath '/user/zybiro/load/temp/kidsfeaturecode.csv' INto table zybiro.kids_featurecode
建表完成。
此处路径根据每次建表实际路径自行替换。
 */

-- 0.把退货订单的AWB做成csv文件，保存一列AWB即可，不需要表头字段；
-- neo_returned_awb.csv
-- /user/zybiro/load/temp/neo_returned_awb.csv
-- 1.运行建表语句
CREATE TABLE zybiro.neo_returned_awb(awb string)
row format delimited fields terminated by '\t'
lines terminated by '\n'
stored AS textfile
-- 2.把csv文件导入到创建的表中；
load data INpath '/user/zybiro/load/temp/neo_returned_awb.csv' INto table zybiro.neo_returned_awb
-- 3.用上表关联， 查询所需结果；
WITH t1 AS
(SELECT p1.invoice_no
        ,(CASE WHEN p1.depod_id = 4 THEN 'GZ2'
                      WHEN p1.depod_id IN (5, 14) THEN 'DG1'
                      WHEN p1.depod_id = 6 THEN 'HK1'
                      WHEN p1.depod_id = 7 THEN 'SA1'
                      WHEN p1.depod_id = 8 THEN 'USA1'
                      ELSE 'Others' END) AS depot
        ,MAX(shipping_time) AS shipping_time
FROM zydb.dw_order_sub_order_fact p1
GROUP BY INvoice_no
        ,(CASE WHEN p1.depod_id = 4 THEN 'GZ2'
                      WHEN p1.depod_id IN (5, 14) THEN 'DG1'
                      WHEN p1.depod_id = 6 THEN 'HK1'
                      WHEN p1.depod_id = 7 THEN 'SA1'
                      WHEN p1.depod_id = 8 THEN 'USA1'
                      ELSE 'Others' END)
)
SELECT p1.awb
        ,t1.depot
        ,t1.shipping_time
FROM zybiro.neo_returned_awb p1
LEFT JOIN t1
         ON p1.awb = t1.invoice_no
;



-- 仓库添加的拣货异常和打包异常 =======================================================================
-- 拣货异常
-- jolly.who_wms_picking_exception_detail
-- 打包异常
-- jolly.who_wms_pack_exception_detail

WITH
-- 拣货异常
t1 AS
(SELECT p1.sku_id
        ,p1.goods_id
        ,p1.order_id
        ,p1.order_sn
        ,p1.depot_id
        ,p1.exception_num
        ,FROM_UNIXTIME(gmt_created) AS add_time
        ,'拣货异常' AS type
FROM jolly.who_wms_picking_exception_detail AS p1
WHERE p1.status = 0
),
-- 打包异常
t2 AS
(SELECT p1.sku_id
        ,p1.goods_id
        ,p1.order_id
        ,p1.order_sn
        ,p1.depot_id
        ,p1.exception_num
        ,FROM_UNIXTIME(gmt_created) AS add_time
        ,'打包异常' AS type
FROM jolly.who_wms_pack_exception_detail AS p1
WHERE p1.status = 0
     AND p1.gmt_created >= UNIX_TIMESTAMP('2017-01-01')
),
-- UNION ALL
t3 AS
(SELECT t1.* FROM t1
UNION ALL
SELECT t2.* FROM t2
),
t4 AS
-- 加上订单的信息
(SELECT t3.sku_id
        ,t3.order_id
        ,t3.order_sn
        ,t3.depot_id
        ,t3.exception_num
        ,t3.add_time
        ,t3.type
        ,p2.original_goods_number
        ,p2.goods_number
        ,p2.pay_time
        ,p4.supp_name
FROM t3
LEFT JOIN zydb.dw_order_node_time p2
             ON t3.order_id = p2.order_id
LEFT JOIN zydb.dw_order_goods_fact p3
             ON t3.order_id = p3.order_id AND t3.sku_id = p3.sku_id
LEFT JOIN zydb.dim_jc_goods p4
             ON p3.goods_id = p4.goods_id
)
SELECT SUM(exception_num)
FROM t4
;


SELECT *
FROM t4
LIMIT 10;

-- 已发货运单号和对应的发货时间
WITH t10 AS
(SELECT p1.invoice_no
        ,p1.shipping_time
FROM zydb.dw_order_sub_order_fact p1
WHERE p1.shipping_time >= '2017-10-01'
     AND p1.shipping_time < '2017-11-01'
     AND p1.is_shiped = 1
)
SELECT *
FROM t10
;

-- 知希 产能计划数据  ===================================================================
WITH
-- 实际销售数据，不分仓
-- 年、月、日销售额，销售订单数，销售商品数， 各月峰值：销售订单数、销售商品数
t101 AS
(SELECT TO_DATE(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END) AS pay_date
        ,SUBSTR(TO_DATE(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END), 1, 4) AS pay_year
        ,SUBSTR(TO_DATE(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END), 6, 2) AS pay_month
        ,SUBSTR(TO_DATE(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END), 9, 2) AS pay_day
        ,COUNT(DISTINCT order_id) AS paid_order_num
        ,SUM(order_amount_no_bonus) AS order_amount_no_bonus
        ,SUM(original_goods_number) AS original_goods_num
FROM zydb.dw_order_fact p1
WHERE p1.pay_status IN (1, 3)
     AND site_id IN (400, 600, 602, 700, 800, 900)
     AND TO_DATE(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END) >= '2016-01-01'
GROUP BY TO_DATE(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END)
),
-- 年月汇总，得到合计和峰值
t102 AS
(SELECT pay_year
        ,pay_month
        ,SUM(paid_order_num) AS paid_order_num
        ,SUM(order_amount_no_bonus) AS order_amount_no_bonus
        ,SUM(original_goods_num) AS original_goods_num
        ,MAX(paid_order_num) AS max_paid_order_num
        ,MAX(original_goods_num) AS max_original_goods_num
FROM t101
GROUP BY pay_year
        ,pay_month
)

-- 需求2：得到每天的销售数据
SELECT *
FROM t101
WHERE pay_month IN ('05', '06', '08', '09', '11', '12')
;

-- 实际出库数据，分仓（海外仓、国内仓）
-- 发货订单数、发货商品数
--各月峰值：发货订单数、发货商品数
t201 AS
(SELECT SUBSTR(p1.shipping_time, 1, 10) AS ship_date
        ,SUBSTR(p1.shipping_time, 1, 4) AS ship_year
        ,SUBSTR(p1.shipping_time, 6, 2) AS ship_month
        ,SUBSTR(p1.shipping_time, 9, 2) AS ship_day
        ,(CASE WHEN p1.depot_id IN (7, 8, 15) THEN '海外仓' ELSE '国内仓' END) AS depot
        ,COUNT(DISTINCT p1.order_id) AS shiped_order_num
        ,SUM(p1.goods_number) AS shiped_goods_num
FROM zydb.dw_order_node_time p1
WHERE p1.shipping_time >= '2016-01-01'
     AND p1.is_shiped = 1
GROUP BY SUBSTR(p1.shipping_time, 1, 10)
        ,SUBSTR(p1.shipping_time, 1, 4)
        ,SUBSTR(p1.shipping_time, 6, 2)
        ,SUBSTR(p1.shipping_time, 9, 2)
        ,(CASE WHEN p1.depot_id IN (7, 8, 15) THEN '海外仓' ELSE '国内仓' END)
),
-- 年月汇总，得到合计和峰值
t202 AS
(SELECT ship_year
        ,ship_month
        ,depot
        ,SUM(shiped_order_num) AS shiped_order_num
        ,SUM(shiped_goods_num) AS shiped_goods_num
        ,MAX(shiped_order_num) AS max_shiped_order_num
        ,MAX(shiped_goods_num) AS max_shiped_goods_num
FROM t201
GROUP BY ship_year
        ,ship_month
        ,depot
)

-- 需求2：得到每天的发货数据
SELECT *
FROM t201
WHERE ship_month IN ('05', '06', '08', '09', '11', '12')
;


-- 历史库存数据，分仓（海外仓、国内仓）
-- 各月峰值：库存sku数、库存件数
t301 AS
-- 国内仓
(SELECT p1.data_date
        ,SUBSTR(p1.data_date, 1, 4) AS data_year
        ,SUBSTR(p1.data_date, 5, 2) AS data_month
        ,SUBSTR(p1.data_date, 7, 2) AS data_day
        ,'国内仓' AS depot
        ,COUNT(DISTINCT p1.sku_id) AS sku_COUNT
        ,SUM(p1.stock_num) AS total_stock_num
FROM zydb.ods_who_wms_goods_stock_detail p1
GROUP BY p1.data_date
        ,SUBSTR(p1.data_date, 1, 4)
        ,SUBSTR(p1.data_date, 5, 2)
        ,SUBSTR(p1.data_date, 7, 2)
        ,'国内仓'
),
t3011 AS
(SELECT AS data_year
        ,data_month
        ,t301.depot
        ,MAX(t301.sku_COUNT) AS max_sku_COUNT
        ,MAX(t301.total_stock_num) AS max_total_stock_num
FROM t301
GROUP BY data_year
        ,data_month
        ,t301.depot
),

t302 AS
-- 海外仓
(SELECT p1.ds AS data_date
        ,SUBSTR(p1.ds, 1, 4) AS data_year
        ,SUBSTR(p1.ds, 5, 2) AS data_month
        ,SUBSTR(p1.ds, 7, 2) AS data_day
        ,'海外仓' AS depot
        ,COUNT(DISTINCT p1.sku_id) AS sku_COUNT
        ,SUM(p1.total_stock_num) AS total_stock_num
        --,SUM(p1.total_stock_num - p1.total_order_lock_num - p1.total_allocate_lock_num - p1.total_return_lock_num) AS free_stock_num
FROM jolly_wms.who_wms_goods_stock_total_detail_daily p1
GROUP BY p1.ds
        ,SUBSTR(p1.ds, 1, 4)
        ,SUBSTR(p1.ds, 5, 2)
        ,SUBSTR(p1.ds, 7, 2)
        ,'海外仓'
),
t3022 AS
(SELECT data_year
        ,data_month
        ,t302.depot
        ,MAX(t302.sku_COUNT) AS max_sku_COUNT
        ,MAX(t302.total_stock_num) AS max_total_stock_num
FROM t302
GROUP BY data_year
        ,data_month
        ,t302.depot
)

-- 需求2：得到每天的库存数据
SELECT *
FROM t301
WHERE t301.data_month IN ('05', '06', '08', '09', '11', '12')
UNION ALL
SELECT *
FROM t302
WHERE t302.data_month IN ('05', '06', '08', '09', '11', '12')



-- 历史库存：从oracle中查询的结果，包含国内海外仓
t301 AS
(SELECT TO_CHAR(p1.data_date, 'yyyy') AS data_year
        ,TO_CHAR(p1.data_date, 'mm') AS data_month
        ,p1.data_date
        ,(CASE WHEN p1.depot_id IN (7, 8, 15) THEN '海外仓' ELSE '国内仓' END) AS depot
        ,SUM(p1.stock_num) AS total_stock_num
FROM zybi.ods_who_wms_goods_stock_dtl p1
GROUP BY TO_CHAR(p1.data_date, 'yyyy')
        ,TO_CHAR(p1.data_date, 'mm')
        ,p1.data_date
        ,(CASE WHEN p1.depot_id IN (7, 8, 15) THEN '海外仓' ELSE '国内仓' END)
),
-- 年月合计和峰值
t302 AS
(SELECT data_year
        ,data_month
        ,depot
        ,SUM(total_stock_num) AS total_stock_num
        ,MAX(total_stock_num) AS max_total_stock_num
FROM t301
GROUP BY data_year
        ,data_month
        ,depot
)

SELECT *
FROM t302




-- SA1仓春节备货事宜 ================================================================
-- 工作核心：根据销售的需求，调控退货商品的入库节奏和已入库商品的清理，保留已销售所需的库存量和保留可销售商品；
/*
1、库存及商品盘点（三个时间节点：当前、2.5、3.11）
            各节点的总库存=【当前】仓库库存+【当前】拒签在途（拒签或退货但未入仓库）+【新增】拒签退货- 【消耗】
        a). 【当前】仓库库存商品盘点，分整体、各品类、季节性的存量及动销情况                                --政鸣
        b). 【当前】拒签在途商品盘点，需考虑当前SKU是否在架，分整体、各品类、季节性的存量         --云英
        c). 【新增】新增拒签退货的商品预估，需考虑订单签收率的预估，分整体、各品类、季节性         --小马
        d). 【消耗】各个阶段内的商品消耗预估，历史的周转天数，分整体、各品类、季节性                   --云英
2、库存释放评估
          由于只有沙特1仓，能够进行分炼操作，且库容有限，需要清除死库存商品，考虑季节性，评估能够腾出多少库容   --政鸣
3、春节期间（2.5~3.11）沙仓的销售情况
         根据2月5号时间节点时的商品结构，结合历史的动销情况，预估沙特仓的销售      --云英
 */

-- 【当前】库存结构和可释放仓容：
-- 1.正品，剔除掉次品
-- 2.划分一二三级类目和季节
-- 3.加上动销情况（销售量和库存，计算动销率和周转？），评估可以释放的仓容
-- 目的：了解当前库存的结构是否合理，根据需要决定是否释放一定的仓容，调整当前的库存结构

-- 把 jolly_wms.who_wms_goods_stock_detail p1表的数据保存，避免后续无法查询26日凌晨的库存数据
CREATE TABLE zybiro.neo_who_wms_goods_stock_detail_sa_20171225
AS
SELECT *
FROM jolly_wms.who_wms_goods_stock_detail p1
WHERE p1.stock_num > 0
     AND p1.depot_id = 7
;

WITH t1 AS
(SELECT j.cat_level1_name
        ,j.cat_level2_name
        ,j.cat_level3_name
        ,(CASE WHEN j.goods_season = 1 THEN '春'
                      WHEN j.goods_season = 2 THEN '夏'
                      WHEN j.goods_season = 3 THEN '秋'
                      WHEN j.goods_season = 4 THEN '冬'
                      WHEN j.goods_season = 5 THEN '春夏'
                      WHEN j.goods_season = 6 THEN '春秋'
                      WHEN j.goods_season = 7 THEN '春冬'
                      WHEN j.goods_season = 8 THEN '夏秋'
                      WHEN j.goods_season = 9 THEN '夏冬'
                      WHEN j.goods_season = 10 THEN '秋冬'
                      ELSE '其他' END) AS good_season
        ,SUM(e.stock_num) AS stock_num
FROM jolly_wms.who_wms_depot_shelf_area a
         ,jolly_wms.who_wms_depot_shelf b
         ,jolly_wms.who_wms_depot_channel c
         ,jolly_wms.who_wms_depot_area d
         ,zybiro.neo_who_wms_goods_stock_detail_sa_20171225 e
         ,zydb.dim_jc_goods j
WHERE a.depot_shelf_id = b.shelf_id
     AND b.depot_channel_id = c.channel_id
     AND c.depot_area_id = d.depot_area_id
     AND a.shelf_area_id = e.shelf_area_id
     AND e.goods_id = j.goods_id
     AND d.depot_area_type_id = 1       -- =1表示正品
GROUP BY j.cat_level1_name
        ,j.cat_level2_name
        ,j.cat_level3_name
        ,(CASE WHEN j.goods_season = 1 THEN '春'
                      WHEN j.goods_season = 2 THEN '夏'
                      WHEN j.goods_season = 3 THEN '秋'
                      WHEN j.goods_season = 4 THEN '冬'
                      WHEN j.goods_season = 5 THEN '春夏'
                      WHEN j.goods_season = 6 THEN '春秋'
                      WHEN j.goods_season = 7 THEN '春冬'
                      WHEN j.goods_season = 8 THEN '夏秋'
                      WHEN j.goods_season = 9 THEN '夏冬'
                      WHEN j.goods_season = 10 THEN '秋冬'
                      ELSE '其他' END)
)
SELECT *
FROM t1
LIMIT 10;

-- 筛选滞销品
-- zybiro.t_yf_stock_monitor_v1_12

WITH t1 AS
(SELECT p1.cat1_name
        ,p1.cat2_name
        ,p1.supp_name
        ,p1.zx_type_old
        ,p1.zx_level_old
        ,(CASE WHEN p2.goods_season = 1 THEN '春'
                      WHEN p2.goods_season = 2 THEN '夏'
                      WHEN p2.goods_season = 3 THEN '秋'
                      WHEN p2.goods_season = 4 THEN '冬'
                      WHEN p2.goods_season = 5 THEN '春夏'
                      WHEN p2.goods_season = 6 THEN '春秋'
                      WHEN p2.goods_season = 7 THEN '春冬'
                      WHEN p2.goods_season = 8 THEN '夏秋'
                      WHEN p2.goods_season = 9 THEN '夏冬'
                      WHEN p2.goods_season = 10 THEN '秋冬'
                      ELSE '其他' END) AS good_season
        ,COUNT(p1.goods_id) AS goods_COUNT
        ,SUM(p1.fre_stk_cnt_07) AS free_stock_num
FROM zybiro.t_yf_stock_monitor_v1_12 p1
LEFT JOIN zydb.dim_jc_goods p2
        ON p1.goods_id = CAST(p2.goods_id AS string)
WHERE p1.ds = '20171225'
GROUP BY p1.cat1_name
        ,p1.cat2_name
        ,p1.supp_name
        ,p1.zx_type_old
        ,p1.zx_level_old
        ,(CASE WHEN p2.goods_season = 1 THEN '春'
                      WHEN p2.goods_season = 2 THEN '夏'
                      WHEN p2.goods_season = 3 THEN '秋'
                      WHEN p2.goods_season = 4 THEN '冬'
                      WHEN p2.goods_season = 5 THEN '春夏'
                      WHEN p2.goods_season = 6 THEN '春秋'
                      WHEN p2.goods_season = 7 THEN '春冬'
                      WHEN p2.goods_season = 8 THEN '夏秋'
                      WHEN p2.goods_season = 9 THEN '夏冬'
                      WHEN p2.goods_season = 10 THEN '秋冬'
                      ELSE '其他' END)
)
SELECT *
FROM t1
;


-- 缺货明细 =======================================
WITH t1 AS
(SELECT
        b.order_sn, b.site_id, b.goods_number  order_goods_number,b.order_amount_no_bonus,
  CASE WHEN b.pay_id=41 THEN  b.pay_time ELSE b.result_pay_time END AS pay_time,
        f.supp_name,
        c.goods_id,c.goods_number,c.goods_price,
        a.sku_id,
        a.TYPE,
        a.oos_num,
        FROM_UNIXTIME(a.create_time) create_time,
        f.provide_code,
       f.cat_level1_name  cat_name,
       f.cat_level2_name sub_cat_name,
       b.depod_id,
      f.first_on_sale_time,
     c2.status,
     c2.is_stock,
  t.free_num
FROM   jolly.who_wms_order_oos_log a
   INner join         zydb.dw_order_sub_order_fact b  ON  a.order_id=b.order_id
  left  join    zydb.dw_order_goods_fact c        ON  b.order_id=c.order_id  AND a.sku_id=c.sku_id
  left  join     jolly.who_sku_depot_coverage_area_status c2  ON  c2.goods_id=c.goods_id AND c2.sku_id=a.sku_id AND depot_coverage_area_id =1
     LEFT JOIN       zydb.dim_jc_goods f              ON  f.goods_id = c.goods_id
  LEFT JOIN     zybiro.yf_oos_detail_stock   t       ON b.depod_id = t.depot_id  AND a.sku_id=t.sku_id
WHERE  1=1
--AND TO_DATE(FROM_UNIXTIME(a.create_time)) >= date_sub(FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyy-MM-dd'),1)
--AND TO_DATE(FROM_UNIXTIME(a.create_time)) < date_sub(FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyy-MM-dd'),0)
     AND a.create_time >= UNIX_TIMESTAMP('2017-11-11')
     AND a.create_time < UNIX_TIMESTAMP('2017-12-21')
)
SELECT *
FROM t1
;


-- 国内，供应商发货的物流记录
-- jolly_tms_center.tms_domestic_order_shipping_tracking_detail
-- 物流信息存放在tracking_detail字段中，尚未解析
-- "UniqId":3这一块是揽件信息，col_008字段表示的是揽件时间
SELECT *
FROM jolly_tms_center.tms_domestic_order_shipping_tracking_detail
LIMIT 10;

-- 解析揽件时间
SELECT p1.*
        ,GET_JSON_OBJECT(p1.tracking_detail,'$.datAS[3].col_008')
FROM jolly_tms_center.tms_domestic_order_shipping_tracking_detail p1
LIMIT 10;

-- 物流到货签收时间（非jollychic系统签收时间）
-- 有15的取15，没15的取14，没14的取13。。。
-- 或者更精准的选择：uniqId = 100
SELECT p1.*
        ,GET_JSON_OBJECT(p1.tracking_detail,'$.datAS[14].col_008')
        ,GET_JSON_OBJECT(p1.tracking_detail,'$.datAS[15].col_008')
        ,GET_JSON_OBJECT(p1.tracking_detail,'$.datAS[-1].col_008')
FROM jolly_tms_center.tms_domestic_order_shipping_tracking_detail p1
LIMIT 20;

SELECT p1.*
        -- 一共多少个环节
        ,CAST(GET_JSON_OBJECT(p1.tracking_detail,'$.dataCOUNT') AS INT)
        -- 取出各个环节的时间
        ,GET_JSON_OBJECT(p1.tracking_detail,'$.datAS[:1].col_008')
        -- 最后一个时间是到货签收时间
        ,SUBSTR(GET_JSON_OBJECT(p1.tracking_detail,'$.datAS[:1].col_008'), -18, 16)
FROM jolly_tms_center.tms_domestic_order_shipping_tracking_detail p1
LIMIT 20;


-- 锁定明细中的status
SELECT p1.status
        ,SUM(p1.org_num)
        ,SUM(p1.oos_num)
FROM jolly_oms.who_wms_goods_need_lock_detail AS p1
WHERE p1.source_type = 1
GROUP BY p1.status;


-- 中间层：到货签收质检上架明细表
SELECT p1.*
FROM zydb.dw_delivered_receipt_onself p1
WHERE p1.END_receipt_time IS NOT NULL
     AND p1.finish_check_time IS NOT NULL
     AND p1.on_shelf_finish_time IS NOT NULL
LIMIT 10;


-- 国内物流商
-- value_name是物流商名称，用的是中文缩写
SELECT p1.value_id AS shipping_id
        ,p1.value_name AS shipping_name
FROM jolly.who_pur_set_value p1
WHERE type_id=16        -- type_id = 16代表物流商


-- 发货时效
SELECT SUBSTR(p1.pay_time, 1, 7) AS pay_month
        ,COUNT(p1.order_id) AS order_num
        ,AVG((UNIX_TIMESTAMP(p1.shipping_time) - UNIX_TIMESTAMP(p1.pay_time))/3600) AS ship_duration
FROM zydb.dw_order_node_time p1
WHERE p1.pay_time >= '2016-01-01'
     AND p1.pay_time < '2018-01-01'
     AND p1.is_shiped = 1
     AND p1.order_status = 1
     AND p1.depot_id IN (1, 2, 3, 4, 5, 6)
     AND p1.shipping_time IS NOT NULL
     AND p1.pay_time IS NOT NULL
GROUP BY SUBSTR(p1.pay_time, 1, 7)
ORDER BY pay_month
;



-- 仓库作业时长：质检时长、上架时长、拣货时长、打包时长、发货时长
WITH
-- 质检时长和质检数量
t1 AS
(SELECT SUBSTR(p1.on_shelf_start_time, 1, 7) AS data_month
        ,SUM(((UNIX_TIMESTAMP(p1.on_shelf_start_time) - UNIX_TIMESTAMP(p1.start_receipt_time))/3600/24) * p1.num)/SUM(p1.num)*24 AS qc_duration
        ,SUM(p1.num) AS qc_num
FROM zydb.dw_delivered_receipt_onself AS p1
WHERE p1.on_shelf_start_time >= '2016-01-01'
     AND p1.on_shelf_start_time < '2018-01-01'
     AND p1.on_shelf_start_time > p1.start_receipt_time
GROUP BY SUBSTR(p1.on_shelf_start_time, 1, 7)
),
-- 上架时长
t2 AS
(SELECT SUBSTR(p1.on_shelf_finish_time, 1, 7) AS data_month
        ,SUM(((UNIX_TIMESTAMP(p1.on_shelf_finish_time) - UNIX_TIMESTAMP(p1.on_shelf_start_time))/3600/24) * p1.on_shelf_num)/SUM(p1.on_shelf_num)*24 AS onshelf_duration
        ,SUM(p1.on_shelf_num) AS onshelf_num
FROM zydb.dw_delivered_receipt_onself AS p1
WHERE p1.on_shelf_finish_time >= '2016-01-01'
     AND p1.on_shelf_finish_time < '2018-01-01'
     AND p1.on_shelf_finish_time > p1.on_shelf_start_time
GROUP BY SUBSTR(p1.on_shelf_finish_time, 1, 7)
),
/*-- 拣货完成时间
-- 拣货完成时间不全，暂不取
t3 AS
(SELECT p1.picking_id
        ,p2.order_id
        ,p1.gmt_created AS pick_begin_time
        ,p1.finish_time AS pick_finish_time
FROM jolly.who_wms_picking_info AS p1
INNER JOIN jolly.who_wms_picking_goods_detail AS p2
        ON p1.picking_id = p2.picking_id
GROUP BY p1.picking_id
        ,p2.order_id
        ,p1.gmt_created
        ,p1.finish_time
),
-- 出库三个环节的时长
-- 由于拣货完成时间缺失，使用总出库时长替代
-- 部分outing_stock_time和shipping_time缺失，暂不可用
t4 AS
(SELECT SUBSTR(p1.shipping_time, 1, 7) AS data_month
        --,SUM((t3.pick_finish_time - UNIX_TIMESTAMP(p1.outing_stock_time))/3600/24)/COUNT(p1.order_id)*24 AS pick_duration
        --,SUM((UNIX_TIMESTAMP(p1.order_pack_time) - t3.pick_finish_time)/3600/24)/COUNT(p1.order_id)*24 AS pack_duration
        ,SUM((UNIX_TIMESTAMP(p1.shipping_time) - UNIX_TIMESTAMP(p1.outing_stock_time))/3600/24)/COUNT(p1.order_id)*24 AS out_wh_duration
        ,COUNT(p1.order_id) AS ship_order_num
FROM zydb.dw_order_node_time p1
WHERE p1.is_shiped = 1
  AND p1.shipping_time >= '2016-01-01'
  AND p1.shipping_time < '2018-01-01'
  AND p1.shipping_time IS NOT NULL
  --AND p1.order_pack_time IS NOT NULL
  --AND t3.pick_finish_time IS NOT NULL
  AND p1.outing_stock_time IS NOT NULL
  AND p1.shipping_time > p1.outing_stock_time
  --AND p1.order_pack_time > FROM_UNIXTIME(t3.pick_finish_time)
  --AND t3.pick_finish_time > UNIX_TIMESTAMP(p1.outing_stock_time)
GROUP BY SUBSTR(p1.shipping_time, 1, 7)
),*/
-- 从原始业务表中取outing_stock_time和shipping_time
-- 1.outing_stock_time
t3 AS
(SELECT p1.order_id
        ,max(NVL(p1.gmt_created, 0)) AS outing_stock_time
FROM jolly.who_wms_outing_stock_detail AS p1
GROUP BY p1.order_id
),
-- 2.用子单表关联t3，取得出库时长和出库订单数
t4 AS
(SELECT SUBSTR(p1.shipping_time, 1, 7) AS data_month
        ,SUM((UNIX_TIMESTAMP(p1.shipping_time) - t3.outing_stock_time)/3600/24)/COUNT(p1.order_id)*24 AS out_wh_duration
        ,COUNT(p1.order_id) AS ship_order_num
FROM zydb.dw_order_sub_order_fact AS p1
LEFT JOIN t3
       ON p1.order_id = t3.order_id
WHERE p1.is_shiped = 1
  AND p1.shipping_time >= '2016-01-01'
  AND p1.shipping_time < '2018-01-01'
  AND p1.shipping_time IS NOT NULL
  AND p1.shipping_time > FROM_UNIXTIME(t3.outing_stock_time)
GROUP BY SUBSTR(p1.shipping_time, 1, 7)
)

SELECT t1.data_month
        ,t1.qc_duration + t2.onshelf_duration AS in_wh_duration
        ,t1.qc_num
        ,t2.onshelf_num
        ,t4.out_wh_duration
        ,t4.ship_order_num
FROM t1
LEFT JOIN t2
       ON t1.data_month = t2.data_month
LEFT JOIN t4
       ON t1.data_month = t4.data_month
ORDER BY data_month
;



-- 个性化专题的评论【数据量少】
SELECT *
FROM jolly.who_edtion_comments p1
LIMIT 20;

-- 商品评论留言表【可用】
SELECT *
FROM jolly_split_order_user.who_goods_comment_message p1
LIMIT 20;


-- 右侯需求，2017年月度数据汇总 ==================================================
-- 审核与配货时效，从付款至可拣货
-- 发货时效1，从可拣货至发货
-- 发货时效1，从付款至发货
-- 运输与配送时效，从发货至签收
-- 区分中国仓和沙特仓

SELECT SUBSTR(p1.pay_time, 1, 7) AS pay_month
        ,(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN 'CN仓' ELSE 'SA仓' END) AS depot
        ,COUNT(p1.order_id) AS pay_order_num    --付款子单数
        ,SUM(CASE WHEN p1.outing_stock_time IS NULL THEN 0 ELSE 1 END) AS outing_stock_order_num    -- 有可出库时间订单数
        ,SUM(CASE WHEN p1.outing_stock_time IS NULL THEN 0
                  ELSE UNIX_TIMESTAMP(p1.outing_stock_time) - UNIX_TIMESTAMP(p1.pay_time)
             END) AS pay_outing_stock_total_time    -- 从付款至可出库的总时间
        ,SUM(CASE WHEN p1.shipping_time IS NULL OR p1.outing_stock_time IS NULL THEN 0 ELSE 1 END) AS ship_order_num1    --有发货时间的订单数
        ,SUM(CASE WHEN p1.shipping_time IS NULL OR p1.outing_stock_time IS NULL THEN 0
                  ELSE UNIX_TIMESTAMP(p1.shipping_time) - UNIX_TIMESTAMP(p1.outing_stock_time)
             END) AS outing_stock_ship_total_time    -- 从可出库至发货的总时间
        ,SUM(CASE WHEN p1.shipping_time IS NULL THEN 0 ELSE 1 END) AS ship_order_num2    --有发货时间的订单数
        ,SUM(CASE WHEN p1.shipping_time IS NULL THEN 0
                  ELSE UNIX_TIMESTAMP(p1.shipping_time) - UNIX_TIMESTAMP(p1.pay_time)
             END) AS pay_ship_total_time    -- 从付款至发货的总时间
        ,SUM(CASE WHEN p2.receipt_time IS NULL OR p1.shipping_time IS NULL THEN 0 ELSE 1 END) AS receipt_order_num     --有签收时间的订单数
        ,SUM(CASE WHEN p2.receipt_time IS NULL OR p1.shipping_time IS NULL THEN 0
                  ELSE UNIX_TIMESTAMP(p2.receipt_time) - UNIX_TIMESTAMP(p1.shipping_time)
             END) AS ship_receipt_total_time    --从发货至签收的总时间
        ,SUM(CASE WHEN p2.receipt_time IS NULL IS NULL THEN 0
                  ELSE UNIX_TIMESTAMP(p2.receipt_time) - UNIX_TIMESTAMP(p1.pay_time)
             END) AS pay_receipt_total_time    --从付款至签收的总时间
FROM zydb.dw_order_node_time AS p1
LEFT JOIN zydb.dw_order_shipping_tracking_node AS p2
       ON p1.order_id = p2.order_id
WHERE p1.pay_time >= '2017-01-01'
  AND p1.pay_time < '2018-01-01'
  AND p1.depot_id IN (4, 5, 6, 7, 14)
GROUP BY SUBSTR(p1.pay_time, 1, 7)
        ,(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN 'CN仓' ELSE 'SA仓' END)
ORDER BY pay_month
        ,depot
;


-- 配货时长分布 =================================================================
-- 根据配货日期来统计
WITH
-- 1.各订单配货时长
t1 AS
(SELECT p1.order_id
        ,p1.outing_stock_time
        ,p1.pay_time
        ,SUBSTR(p1.outing_stock_time, 1, 10) AS peihuo_date
        ,DATEDIFF(p1.outing_stock_time, p1.pay_time) AS peihuo_days
FROM zydb.dw_order_node_time AS p1
WHERE p1.outing_stock_time >= '2018-01-01'
  AND p1.outing_stock_time <  '2018-01-29'
  AND p1.order_status = 1
  AND p1.pay_status IN (1, 3)
)
SELECT t1.peihuo_date
        ,t1.peihuo_days
        ,COUNT(t1.order_id) AS order_num
FROM t1
GROUP BY t1.peihuo_date
        ,t1.peihuo_days
ORDER BY t1.peihuo_date
        ,t1.peihuo_days
;

-- 配货时长分布 =================================================================
-- 根据下单日期来统计
WITH
-- 1.各订单配货时长
t1 AS
(SELECT p1.order_id
        ,(CASE WHEN p1.depot_id = 4 THEN 4
               WHEN p1.depot_id = 6 THEN 6
               ELSE 5
          END) AS depot_id
        ,p1.outing_stock_time
        ,p1.pay_time
        ,SUBSTR(p1.pay_time, 1, 10) AS pay_date
        ,DATEDIFF(p1.outing_stock_time, p1.pay_time) AS peihuo_days
FROM zydb.dw_order_node_time AS p1
WHERE p1.pay_time >= '2018-01-01'
  AND p1.pay_time <  '2018-02-01'
  AND p1.order_status = 1
  AND p1.pay_status IN (1, 3)
  AND p1.depot_id IN (4, 5, 6, 14)
)
SELECT t1.pay_date
        ,t1.depot_id
        ,t1.peihuo_days
        ,COUNT(t1.order_id) AS order_num
FROM t1
GROUP BY t1.pay_date
        ,t1.depot_id
        ,t1.peihuo_days
ORDER BY t1.pay_date
        ,t1.depot_id
        ,t1.peihuo_days
;



-- 迪拜仓出库订单商品测算 ========================================================
-- zydb.dw_order_sub_order_fact.country_name = 'United Arab Emirates' = 'United Arab Emirates'
WITH
-- 1.Dubai仓当前库存明细
t1 AS
(SELECT p1.sku_id
        ,SUM(p1.stock_num) AS stock_num
        --,SUM(CASE WHEN p2.status = 0 THEN p1.stock_num ELSE 0 END) AS keshou_stock_num
FROM jolly_wms.who_wms_goods_stock_detail AS p1
LEFT JOIN jolly.who_sku_relation AS p2
       ON p1.sku_id = p2.rec_id
WHERE p1.depot_id = 15
  AND p2.status = 0  --0启用，代表可售
GROUP BY p1.sku_id
),
-- 1.近两周下单的订单和sku明细,sku需是当前库存中的
t2 AS
(SELECT t1.sku_id
        ,p1.order_id
        ,SUBSTR(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END, 1, 10) AS pay_date
        ,p2.goods_number
        ,t1.stock_num
FROM t1
LEFT JOIN zydb.dw_order_goods_fact AS p2
       ON t1.sku_id = p2.sku_id
LEFT JOIN zydb.dw_order_sub_order_fact AS p1
       ON p1.order_id = p2.order_id
WHERE p1.order_status = 1
  AND p1.pay_status IN (1, 3)
  AND p1.country_name = 'United Arab Emirates' = 'United Arab Emirates'
  AND (CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END) >= '2018-01-12'
  AND (CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END) < '2018-02-11'
)
SELECT *
FROM t2
;


-- 迪拜仓每天订单量和商品量
SELECT substr(p1.pay_time, 1, 10) AS pay_date
        ,COUNT(p1.order_id) AS order_num
        ,SUM(p1.goods_number) AS goods_num
FROM zydb.dw_order_node_time AS p1
WHERE p1.depot_id = 15
  AND p1.order_status = 1
  AND p1.pay_status IN (1,3)
GROUP BY substr(p1.pay_time, 1, 10)
ORDER BY pay_date
;


-- UAE市场每天订单量和商品数量
SELECT SUBSTR(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END, 1, 10) AS pay_date
        ,COUNT(p1.order_id) AS order_num
        ,SUM(p1.goods_number) AS goods_num
FROM zydb.dw_order_sub_order_fact AS p1
WHERE p1.order_status = 1
  AND p1.pay_status IN (1, 3)
  AND p1.country_name = 'United Arab Emirates' = 'United Arab Emirates'
  AND p1.pay_time >= '2018-01-12'
  AND p1.pay_time <  '2018-02-11'
GROUP BY SUBSTR(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END, 1, 10)
ORDER BY pay_date
;

-- 迪拜仓类目库存结构
WITH
-- 1.Dubai仓当前库存结构
t101 AS
(SELECT p1.sku_id
        ,p1.goods_id
        ,p1.goods_sn
        ,p1.goods_name
        ,p2.cate_level1_name
        ,p2.cate_level2_name
        ,p2.cate_level3_name
        ,SUM(p1.stock_num) AS total_stock_num
FROM jolly_wms.who_wms_goods_stock_detail AS p1
LEFT JOIN zydb.dim_goods AS p2
       ON p1.goods_id = p2.goods_id
WHERE p1.depot_id = 15
GROUP BY p1.sku_id
        ,p1.goods_id
        ,p1.goods_sn
        ,p1.goods_name
        ,p2.cate_level1_name
        ,p2.cate_level2_name
        ,p2.cate_level3_name
),
-- 一级类目, 二级类目, sku数, 商品件数
t102 AS
(SELECT t101.cate_level1_name
        ,t101.cate_level2_name
        ,COUNT(t101.sku_id) AS sku_COUNT
        ,SUM(t101.total_stock_num) AS total_stock_num
FROM t101
GROUP BY t101.cate_level1_name
        ,t101.cate_level2_name
),
-- 2.UAE市场类目销售结构
t201 AS
(SELECT p3.cate_level1_name
        ,p3.cate_level2_name
        ,SUM(CASE WHEN p1.pay_time >= '2017-01-01' AND p1.pay_time < '2017-02-01' THEN p2.goods_number ELSE 0 END) AS goods_num_201701
        ,SUM(CASE WHEN p1.pay_time >= '2017-02-01' AND p1.pay_time < '2017-03-01' THEN p2.goods_number ELSE 0 END) AS goods_num_201702
        ,SUM(CASE WHEN p1.pay_time >= '2017-03-01' AND p1.pay_time < '2017-04-01' THEN p2.goods_number ELSE 0 END) AS goods_num_201703
        ,SUM(CASE WHEN p1.pay_time >= '2017-04-01' AND p1.pay_time < '2017-05-01' THEN p2.goods_number ELSE 0 END) AS goods_num_201704
        ,SUM(CASE WHEN p1.pay_time >= '2018-01-01' AND p1.pay_time < '2018-02-01' THEN p2.goods_number ELSE 0 END) AS goods_num_201801
FROM zydb.dw_order_node_time AS p1
LEFT JOIN zydb.dw_order_goods_fact AS p2
       ON p1.order_id = p2.order_id
LEFT JOIN zydb.dim_goods AS p3
       ON p2.goods_id = p3.goods_id
WHERE p1.country_name = 'United Arab Emirates' = 'United Arab Emirates'
  AND p1.order_status = 1
  AND p1.pay_status IN (1, 3)
GROUP BY p3.cate_level1_name
        ,p3.cate_level2_name
)
-- 3. full outer join, 得到库存和销售结构
SELECT COALESCE(t102.cate_level1_name, t201.cate_level1_name) AS cat_level1_name
        ,COALESCE(t102.cate_level2_name, t201.cate_level2_name) AS cat_level2_name
        ,t102.sku_COUNT
        ,t102.total_stock_num
        ,t201.goods_num_201701
        ,t201.goods_num_201702
        ,t201.goods_num_201703
        ,t201.goods_num_201704
FROM t102
FULL OUTER JOIN t201
             ON t102.cate_level1_name = t201.cate_level1_name
            AND t102.cate_level2_name = t201.cate_level2_name
ORDER BY cat_level1_name
        ,cat_level2_name
;





-- 盘盈盘亏记录
-- jolly.who_wms_check_stock_detail_log
-- jolly_wms.who_wms_check_stock_detail_log
-- 这些盘盈盘亏记录会汇总到库存变更记录表中：
-- SA仓：jolly_wms.who_wms_goods_stock_detail_log
-- 国内仓：jolly.who_wms_goods_stock_detail_log
SELECT *
FROM jolly.who_wms_check_stock_detail_log
LIMIT 10;

SELECT p1.goods_id
        ,p1.goods_sn
        ,p1.sku_id
        ,p1.sku_value
        ,p1.check_stock_status
        ,p1.change_num
        ,FROM_UNIXTIME(p1.op_time) AS op_time
FROM jolly.who_wms_check_stock_detail_log AS p1
WHERE p1.depot_id IN (5, 14)
  AND p1.check_stock_status IN (1, 2)
  AND p1.op_time >= UNIX_TIMESTAMP('2018-01-21')
  AND p1.op_time < UNIX_TIMESTAMP('2018-01-22')
;


-- 迪拜仓备货商品销售预测
WITH
-- 预测销售数量
t1 AS
(SELECT p1.goods_id
        ,p1.sku_id
        ,SUM(CASE WHEN p1.data_date >= '2018-04-01' AND p1.data_date < '2018-05-01' THEN p1.goods_number ELSE 0 END) AS sale_num_04
        ,SUM(CASE WHEN p1.data_date >= '2018-05-01' AND p1.data_date < '2018-06-01' THEN p1.goods_number ELSE 0 END) AS sale_num_05
        ,SUM(CASE WHEN p1.data_date >= '2018-04-01' AND p1.data_date < '2018-06-01' THEN p1.goods_number ELSE 0 END) AS sale_num_0405
FROM zybiro.neo_dubai_beihuo_sale_predict AS p1
GROUP BY p1.goods_id
        ,p1.sku_id
),
-- join, 得到备货商品的备货量和预测销量
t2 AS
(SELECT p1.*
        ,t1.sale_num_04
        ,t1.sale_num_05
        ,t1.sale_num_0405
        ,p2.cate_level1_name
        ,p2.cate_level2_name
FROM zybiro.neo_dubai_beihuo_sku_detail2 AS p1
LEFT JOIN t1
       ON p1.sku_id = t1.sku_id
LEFT JOIN zydb.dim_goods AS p2
       ON p1.goods_id = p2.goods_id
)

SELECT *
FROM t2
;
-- 导出到excel中处理


-- 哪些sku的近期销售为0？
WITH
t1 AS
(SELECT a.goods_id
        ,a.sku_id
        ,SUM(a.goods_number) AS goods_num
FROM zybiro.neo_dubai_beihuo_sale_predict a
WHERE a.data_date >= '2017-10-01'
  AND a.data_date < '2018-01-01'
GROUP BY a.goods_id
        ,a.sku_id
)

SELECT goods_id
        ,sku_id
FROM t1
WHERE goods_num = 0
;


-- 沙特仓备货商品销售预测
WITH
-- 预测销售数量
t1 AS
(SELECT p1.goods_id
        ,p1.sku_id
        ,SUM(CASE WHEN p1.data_date >= '2018-04-01' AND p1.data_date < '2018-05-01' THEN p1.goods_number ELSE 0 END) AS sale_num_04
        ,SUM(CASE WHEN p1.data_date >= '2018-04-01' AND p1.data_date < '2018-06-01' THEN p1.goods_number ELSE 0 END) AS sale_num_0405
FROM zybiro.neo_sa_beihuo_sale_predict AS p1
GROUP BY p1.goods_id
        ,p1.sku_id
),
-- join, 得到备货商品的备货量和预测销量
t2 AS
(SELECT p1.*
        ,t1.sale_num_04
        ,t1.sale_num_0405
        ,p2.cate_level1_name
        ,p2.cate_level2_name
FROM zybiro.neo_sa_beihuo_sku_detail2 AS p1
LEFT JOIN t1
       ON p1.sku_id = t1.sku_id
LEFT JOIN zydb.dim_goods AS p2
       ON p1.goods_id = p2.goods_id
)

SELECT *
FROM t2
;
-- 导出到excel中处理



-- 仓储KPI数据
SELECT *
FROM zydb.rpt_warehousing_depart_kpi AS p1
WHERE p1.data_date >= '20171201'
  AND p1.data_date <= '20171231'
;



-- 供应链日报-老，仓库发货异常率
-- 拣货异常订单，导致订单发生退货/未发货
WITH
-- 异常订单数
t1 AS
(SELECT SUBSTR(p1.shipping_time, 1, 7) AS ship_month
        ,COUNT(DISTINCT p1.order_id) abnormal_order --发货异常订单数
FROM zydb.rpt_scm_order_tmp AS p1
INNER JOIN jolly.who_wms_returned_order_info AS p2
        ON p1.order_id = p2.returned_order_id
--AND p2.returned_order_status  IN(3,6,7,8) --modified by hanshizhong 20170308 WMS调整退货标识
       AND p2.return_reASon IN (24)
WHERE p1.is_shiped = 1
  AND p1.depod_id = 4
  AND p1.shipping_time >= '2017-11-01'
  AND p1.shipping_time <  '2018-01-01'
GROUP BY SUBSTR(p1.shipping_time, 1, 7)
),
-- 发货订单数
t2 AS
(SELECT SUBSTR(p1.shipping_time, 1, 7) AS ship_month
        ,COUNT(p1.order_id) AS ship_orders
FROM zydb.dw_order_node_time AS p1
WHERE p1.is_shiped = 1
  AND p1.depot_id = 4
  AND p1.shipping_time >= '2017-11-01'
  AND p1.shipping_time <  '2018-01-01'
GROUP BY SUBSTR(p1.shipping_time, 1, 7)
)
SELECT t2.*
        ,t1.abnormal_order
        ,t1.abnormal_order / t2.ship_orders AS abnormal_order_rate
FROM t2
LEFT JOIN t1
       ON t1.ship_month = t2.ship_month
ORDER BY t2.ship_month
;

-- 订单表中的发货状态is_shiped:是否已发货,0未发货,1已发货,2部分发货,3待发货,4部分匹配,5完全匹配,6拣货完成,7待拣货,8拣货中



-- 卡塔尔国家，完成配货订单，未配货商品，商品明细 ===============================================================
-- 对于未配货的sku，展示未配齐sku、数量、供应商名称
WITH
-- 订单信息
t01 AS
(SELECT p1.pay_time
        ,DATEDIFF(CURRENT_TIMESTAMP(), p1.pay_time) AS pay_duration
        ,p1.order_id
        ,p1.order_sn
        ,p1.site_id
        ,p1.depot_id
        ,p1.is_shiped
        ,p1.order_status
        ,p1.pay_status
        ,p1.is_problems_order
        ,p1.goods_number AS order_goods_num
        ,p1.is_cod
FROM zydb.dw_order_node_time AS p1
WHERE p1.country_name = 'United Arab Emirates' = 'Qatar'
  AND p1.pay_time >= '2018-01-24'
  AND p1.is_shiped <> 1
),
-- 订单未配齐总数量
t02 AS
(SELECT order_id
        ,SUM(num) AS total_still_need_num
FROM jolly.who_wms_goods_need_lock_detail
GROUP BY order_id
),
-- 未配齐sku和数量
t03 AS
(SELECT p1.order_id
        ,p1.sku_id
        ,p1.num AS sku_still_need_num
FROM jolly.who_wms_goods_need_lock_detail AS p1
WHERE p1.num >= 1
),
-- JOIN得到供应商名称
t04 AS
(SELECT TO_DATE(t01.pay_time) AS pay_date
        ,t01.order_id
        ,t01.order_sn
        ,t01.depot_id
        ,t01.is_cod
        ,t01.site_id
        ,(CASE WHEN t01.is_problems_order = 1 THEN '是'
               WHEN t01.is_problems_order = 2 THEN '否'
               ELSE '其他'
          END) AS is_problems_order
        ,(CASE WHEN t01.is_shiped = 0 THEN '未配货'
               WHEN t01.is_shiped = 1 THEN '已发货'
               WHEN t01.is_shiped = 2 THEN '部分发货'
               WHEN t01.is_shiped = 3 THEN '待发货'
               WHEN t01.is_shiped = 4 THEN '部分匹配'
               WHEN t01.is_shiped = 5 THEN '完全匹配'
               WHEN t01.is_shiped = 6 THEN '拣货完成'
               WHEN t01.is_shiped = 7 THEN '待拣货'
               WHEN t01.is_shiped = 8 THEN '拣货中'
               ELSE NULL
          END) AS is_shiped
        ,t01.order_goods_num
        ,t02.total_still_need_num
        ,t03.sku_id
        ,p1.goods_number AS sku_goods_num
        ,t03.sku_still_need_num
        ,p4.cat_level1_name
        ,p4.supp_name
FROM t01
LEFT JOIN t02
       ON t01.order_id = t02.order_id
LEFT JOIN t03
       ON t01.order_id = t03.order_id
LEFT JOIN jolly.who_order_goods AS p1
       ON t03.order_id = p1.order_id AND t03.sku_id = p1.sku_id
LEFT JOIN jolly.who_sku_relation p3
       ON t03.sku_id = p3.rec_id
LEFT JOIN zydb.dim_jc_goods p4
       ON p3.goods_id = p4.goods_id
)

-- 最终结果
SELECT *
FROM t04
ORDER BY pay_date
;

-- jolly.who_goods -- 0. 商品维度表
   -- is_stock：goods_id是否卖库存：0 非卖库存 1卖库存 2deals 4 sku卖库存

-- zydb.dim_goods --1. 商品维度表

-- zydb.dim_goods_extEND --2. 商品维度扩展表(商品在架及价格等信息)
   -- is_jc_enable：是否jc售卖
   -- is_jc_on_sale：是否jc在架

-- jolly.who_sku_relation -- 3. sku_id与goods_id关联表
   -- status：属性是否启用,0启用,1禁用,2删除 默认 0
   -- is_stock：sku_id是否卖库存，0否,1是

SELECT *
FROM zydb.dim_goods_extEND AS p1
WHERE p1.is_jc_enable = 1
LIMIT 10;

-- 春节期间我们想要一个大陆仓库内有库存但是下架的sku明细。
WITH
t1 AS
(SELECT p1.sku_id
        ,p1.goods_id
        ,p2.cate_level1_name
        ,p2.supp_name
        ,(p1.total_stock_num - p1.total_order_lock_num - p1.total_allocate_lock_num - p1.total_return_lock_num) AS free_num
        ,(CASE WHEN p3.is_jc_on_sale = 1 THEN '在架' ELSE '下架' END) AS is_on_sale
        ,(CASE WHEN p5.status = 0 THEN '启用'
               WHEN p5.status = 1 THEN '禁用'
               ELSE '删除'
          END) AS is_qiyong
        ,(CASE WHEN p4.is_stock = 0 THEN '非卖库存'
               WHEN p4.is_stock = 1 THEN '卖库存'
               WHEN p4.is_stock = 2 THEN 'deals'
               WHEN p4.is_stock = 4 THEN 'sku卖库存'
               ELSE '其他'
          END) AS is_goods_stock
        ,(CASE WHEN p5.is_stock = 1 THEN '卖库存' ELSE '非卖库存' END) AS is_sku_stock
FROM zydb.ods_who_wms_goods_stock_total_detail AS p1
LEFT JOIN zydb.dim_goods AS p2
       ON p1.goods_id = p2.goods_id
LEFT JOIN zydb.dim_goods_extEND AS p3
       ON p1.goods_id = p3.goods_id
LEFT JOIN jolly.who_goods AS p4
       ON p1.goods_id = p4.goods_id
LEFT JOIN jolly.who_sku_relation AS p5
       ON p1.sku_id = CAST(p5.sku_id AS INt)
WHERE p1.depot_id IN (4, 5, 14)
  AND p1.data_date = SUBSTR(REGEXP_REPLACE(TO_DATE(DATE_SUB(CURRENT_TIMESTAMP(), 1)), '-', ''), 1, 8)  --昨天库存数据
  AND p3.is_jc_enable = 1
  AND p3.is_jc_on_sale = 0
),
t2 AS
(SELECT t1.sku_id
        ,t1.goods_id
        ,t1.cate_level1_name
        ,t1.supp_name
        ,t1.free_num
        ,t1.is_on_sale
        ,t1.is_qiyong
        ,t1.is_goods_stock
        ,t1.is_sku_stock
FROM t1
WHERE t1.free_num >= 1
GROUP BY t1.sku_id
        ,t1.goods_id
        ,t1.cate_level1_name
        ,t1.supp_name
        ,t1.free_num
        ,t1.is_on_sale
        ,t1.is_qiyong
        ,t1.is_goods_stock
        ,t1.is_sku_stock
)
SELECT *
FROM t2
;



SELECT *
FROM jolly.who_wms_order_oos_log AS p1
LIMIT 10;



-- 供应链2018年kpi计算 胡云蕾 ===================================================
-- 1.沙特仓订单时效
-- 2.沙特仓订单缺货率

WITH
-- 1.订单时效
t01 AS
(SELECT SUBSTR(p1.pay_time, 1, 7) AS pay_month
        ,COUNT(p1.order_id) AS order_num
        ,AVG((UNIX_TIMESTAMP(p1.outing_stock_time) - UNIX_TIMESTAMP(p1.pay_time))/3600) AS peihuo_pay_hour
        ,AVG((UNIX_TIMESTAMP(p1.shipping_time) - UNIX_TIMESTAMP(p1.outing_stock_time))/3600) AS ship_peihuo_hour
FROM zydb.dw_order_node_time AS p1
WHERE p1.is_shiped = 1
  AND p1.depot_id = 7
  AND p1.pay_time >= '2017-01-01'
  AND p1.pay_time <  '2018-01-01'
  AND p1.shipping_time IS NOT NULL
  AND p1.outing_stock_time IS NOT NULL
  AND p1.outing_stock_time >= p1.pay_time
  AND p1.shipping_time >= p1.outing_stock_time
GROUP BY SUBSTR(p1.pay_time, 1, 7)
),
-- 2.缺货订单
t02 AS
(SELECT SUBSTR(p1.pay_time, 1, 7) AS pay_month
        ,COUNT(DISTINCT p2.order_id) AS oos_order_num
FROM zydb.dw_order_node_time AS p1
INNER JOIN jolly.who_wms_order_oos_log AS p2
        ON p1.order_id = p2.order_id
WHERE p1.is_shiped = 1
  AND p1.depot_id = 7
  AND p1.pay_time >= '2017-01-01'
  AND p1.pay_time <  '2018-01-01'
  AND p1.shipping_time IS NOT NULL
  AND p1.outing_stock_time IS NOT NULL
  AND p1.outing_stock_time >= p1.pay_time
  AND p1.shipping_time >= p1.outing_stock_time
GROUP BY SUBSTR(p1.pay_time, 1, 7)
)
SELECT t01.*
        ,(t01.peihuo_pay_hour + t01.ship_peihuo_hour) AS ship_pay_hour
        ,t02.oos_order_num
        ,(t02.oos_order_num / t01.order_num) AS oos_order_rate
FROM t01
LEFT JOIN t02
       ON t01.pay_month = t02.pay_month
ORDER BY t01.pay_month
;


-- 美国土耳其日本三仓订单明细 =================================================================

WITH
-- who_order_info 和 who_order_user_info， 取子单的信息
t01 AS
(SELECT p1.order_id
        ,p1.order_sn
        ,p1.is_shiped
        ,p1.depot_id
        ,p1.site_id
        ,p1.order_status
        ,p1.goods_num
        ,(p1.pay_money+p1.surplus+p1.order_amount) AS order_amount
        ,p1.pay_status
        ,p1.is_problems_order
        --,p2.country_name = 'United Arab Emirates'
        ,FROM_UNIXTIME(IF(p1.prepare_pay_time = 0, p1.pay_time, p1.prepare_pay_time)) AS pay_time
        ,FROM_UNIXTIME(p1.no_problems_order_uptime) AS no_problems_order_uptime
        ,FROM_UNIXTIME(p1.shipping_time) AS shipping_time
        ,(CASE WHEN p1.pay_id = 41 THEN 'cod' ELSE 'not_cod' END) AS is_cod
        ,(CASE WHEN p2.source_order_id IS NOT NULL THEN 1 ELSE 0 END) AS is_split
FROM default.who_order_info AS p1
LEFT JOIN default.who_order_user_info AS p2
       ON p1.order_id = p2.source_order_id
WHERE p1.depot_id IN (8, 10, 13)
GROUP BY p1.order_id
        ,p1.order_sn
        ,p1.is_shiped
        ,p1.depot_id
        ,p1.site_id
        ,p1.order_status
        ,p1.goods_num
        ,(p1.pay_money+p1.surplus+p1.order_amount)
        ,p1.pay_status
        ,p1.is_problems_order
        --,p2.country_name = 'United Arab Emirates'
        ,FROM_UNIXTIME(IF(p1.prepare_pay_time = 0, p1.pay_time, p1.prepare_pay_time))
        ,FROM_UNIXTIME(p1.no_problems_order_uptime)
        ,FROM_UNIXTIME(p1.shipping_time)
        ,(CASE WHEN p1.pay_id = 41 THEN 'cod' ELSE 'not_cod' END)
        ,(CASE WHEN p2.source_order_id IS NOT NULL THEN 1 ELSE 0 END)
),
-- 订单未配齐总数量
t02 AS
(SELECT order_id
        ,SUM(num) AS total_still_need_num
-- FROM jolly_oms.who_wms_goods_need_lock_detail
FROM default.who_wms_goods_need_lock_detail
GROUP BY order_id
),
-- 未配齐sku和数量
t03 AS
(SELECT p1.order_id
        ,p1.sku_id
        ,p1.num AS sku_still_need_num
FROM default.who_wms_goods_need_lock_detail AS p1
WHERE p1.num >= 1
),
-- JOIN得到供应商名称
t04 AS
(SELECT TO_DATE(t01.pay_time) AS pay_date
        ,(CASE WHEN t01.site_id = 0 THEN 'Jollychic'
               WHEN t01.site_id = 1 THEN 'NIMINI'
               WHEN t01.site_id = 2 THEN 'MarkaVIP'
               ELSE 'Others'
           END) AS site_id
        ,t01.order_id
        ,t01.order_sn
        ,t01.depot_id
        ,t01.is_cod
        ,t01.order_status
        ,t01.pay_status
        ,(CASE WHEN t01.is_problems_order = 1 THEN '是'
               WHEN t01.is_problems_order = 2 THEN '否'
               ELSE '其他'
          END) AS is_problems_order
        ,(CASE WHEN t01.is_shiped = 0 THEN '未配货'
                      WHEN t01.is_shiped = 1 THEN '已发货'
                      WHEN t01.is_shiped = 2 THEN '部分发货'
                      WHEN t01.is_shiped = 3 THEN '待发货'
                      WHEN t01.is_shiped = 4 THEN '部分匹配'
                      WHEN t01.is_shiped = 5 THEN '完全匹配'
                      WHEN t01.is_shiped = 6 THEN '拣货完成'
                      WHEN t01.is_shiped = 7 THEN '待拣货'
                      WHEN t01.is_shiped = 8 THEN '拣货中'
                      ELSE NULL END) AS is_shiped
        ,t01.goods_num
        ,t01.order_amount
        --,t01.country_name = 'United Arab Emirates'
        ,t01.pay_time
        ,t01.shipping_time
        ,t02.total_still_need_num
        ,p5.sku_id
        ,p5.goods_number
        ,t03.sku_still_need_num
        ,p4.supp_name
FROM t01
LEFT JOIN t02
             ON t01.order_id = t02.order_id
LEFT JOIN jolly.who_order_goods p5
             ON t01.order_id = p5.order_id
LEFT JOIN t03
             ON p5.order_id = t03.order_id AND p5.sku_id = t03.sku_id
LEFT JOIN jolly.who_sku_relation p3
             ON t03.sku_id = p3.rec_id
LEFT JOIN zydb.dim_jc_goods p4
             ON p3.goods_id = p4.goods_id
WHERE t01.is_split = 0
)

-- 最终结果
SELECT *
FROM t04
ORDER BY pay_time
;


-- 海外仓备货商品流转监控 ========================================================

/*
海外备货单据流转如下：
1.先生成批发订单，4仓/5仓各一个批发订单，4仓发迪拜，5仓发沙特
批发订单表：who_wholesale_order_info
批发订单商品表：who_wholesale_order_goods
2.根据批发订单生成采购需求
3.供应商响应采购需求，生成采购单，发货
4.4/5两仓收货，质检，打包，发货
批发订单作业单表：who_wms_wholesale_picking_info
批发订单作业单商品表：who_wms_wholesale_picking_goods
5.发货后给目的仓生成到货单
问题点：
1.采购到货单与批发订单作业单未关联
2.批发订单作业单未与目的仓到货单关联
*/




SELECT *
FROM jolly.who_wholesale_order_info AS p1
WHERE p1.wholesale_order_id IN (384, 386)
;

/*
-- 初始数量
386 PF180202143007425USF 212468 5
384 PF180202134301600J41 38180 4
*/


SELECT *
FROM jolly.who_wms_wholesale_order_replenishment_detail AS p1
LIMIT 10;

-- 批发订单数量有修正，以SUM(p1.order_num)为准
SELECT p1.wholesale_order_id
        ,SUM(p1.order_org_num) AS org_goods_num
        ,SUM(p1.order_num) AS new_goods_num
        ,SUM(p1.send_num) AS send_num
FROM jolly.who_wholesale_order_goods AS p1
WHERE p1.wholesale_order_id IN (384, 386)
GROUP BY p1.wholesale_order_id
;




--
WITH
t1 AS
(SELECT p1.wholesale_order_id
        ,(CASE WHEN p1.wholesale_order_id = 384 THEN 'guangzhou2' ELSE 'dongguan1' END) AS guonei_depot
        ,(CASE WHEN p1.wholesale_order_id = 384 THEN 'dubai1' ELSE 'saudi2' END) AS guowai_depot
        ,p1.goods_id
        ,p1.sku_id
        ,p1.in_price
        ,p1.shop_price
        ,p1.order_org_num
        ,p1.order_num
        ,p1.send_num AS send_num1
        ,p3.supp_name
        ,p3.send_num AS send_num2
        ,p3.oos_num
        ,p3.real_oos_num
        ,p3.in_price AS in_price2
FROM jolly.who_wholesale_order_goods AS p1
LEFT JOIN jolly.who_wms_goods_need_lock_detail AS p2
       ON p1.rec_id = p2.order_goods_rec_id
LEFT JOIN jolly.who_wms_pur_goods_demAND AS p3
       ON p1.rec_id = p3.source_rec_id
WHERE p1.wholesale_order_id = 384
   OR p1.wholesale_order_id = 386
)

SELECT t1.guonei_depot
        ,SUM(t1.order_num) AS order_num
        ,SUM(CASE WHEN t1.supp_name IS NULL THEN t1.order_num ELSE 0 END) AS no_demAND_num
        ,SUM(t1.send_num1) AS send_num1
        ,SUM(t1.send_num2) AS send_num2
FROM t1
GROUP BY t1.guonei_depot
;

LIMIT 10
;




SELECT *
FROM jolly.who_wms_pur_goods_demAND AS p1
WHERE p1.source_rec_id >= 96344
LIMIT 10;


SELECT *
FROM jolly.who_wholesale_order_goods AS p1
WHERE p1.wholesale_order_id IN (384, 386)
LIMIT 10
;

SELECT *
FROM jolly.who_wholesale_order_goods AS p1
WHERE p1.wholesale_order_id IN (384, 386)
AND p1.send_num > 1
LIMIT 10
;


-- picking_status:0待拣货,1拣货中,2拣货完成,3打包完成,4已出库


SELECT *
FROM jolly.who_wms_wholesale_picking_info AS p1
WHERE p1.picking_time >= UNIX_TIMESTAMP('2018-02-03', 'yyyy-MM-dd')
LIMIT 10;


SELECT *
FROM jolly.who_wms_wholesale_picking_goods AS p1
LIMIT 10;





-- 到货签收和质检

-- 签收：jolly.who_wms_delivered_receipt_info.status 0-未登记 1-已登记 2-已分配质检 3-质检完成 4-发错仓库
-- 质检：jolly.who_wms_delivered_order_goods

WITH
-- 到货单应到数量、实到数量、签收时间、质检数量、质检时间
t1 AS
(SELECT p1.depot_id
        ,p1.delivered_order_sn
        ,p1.total_num
        ,p1.inspect_num
        ,MIN(p1.start_receipt_time) AS receipt_time
        ,MIN(p1.first_check_time) AS begin_qc_time
        ,MAX(p1.finish_check_time) AS finish_qc_time
FROM zydb.dw_delivered_receipt_onself AS p1
GROUP BY p1.depot_id
        ,p1.delivered_order_sn
        ,p1.total_num
        ,p1.inspect_num
),
t2 AS
(SELECT t1.*
FROM t1
WHERE t1.begin_qc_time >= TO_DATE(DATE_SUB(CURRENT_TIMESTAMP(), 1))
  AND t1.begin_qc_time <  TO_DATE(DATE_SUB(CURRENT_TIMESTAMP(), 0))
)
SELECT *
FROM t2
;

SELECT *
FROM jolly.who_wms_delivered_receipt_info AS p1
LIMIT 10;

SELECT *
FROM zydb.dw_delivered_receipt_onself AS p1
LIMIT 10;


-- 到货签收
-- 对应wms系统中的到货单签收界面
SELECT p1.*
FROM jolly.who_wms_delivered_receipt_info AS p1
WHERE p1.tracking_no = '20782047299'
;

-- 查询实到数量少于应到数量的到货单
SELECT p1.*
FROM jolly.who_wms_delivered_receipt_info AS p1
-- WHERE p1.tracking_no = '240403307499'
WHERE p1.real_num < p1.should_num
  AND p1.gmt_created >= UNIX_TIMESTAMP('2018-02-05', 'yyyy-MM-dd')
  AND p1.gmt_created <  UNIX_TIMESTAMP('2018-02-06', 'yyyy-MM-dd')
LIMIT 10
;

-- 沙特仓一单一件订单占比
-- 沙特仓出单商品件数的订单占比
SELECT SUBSTR(p1.shipping_time, 1, 7) AS ship_month
        ,(CASE WHEN p1.goods_number <= 4 THEN '<=4'
               WHEN p1.goods_number = 5 THEN '=5'
               ELSE '>=6'
          END) AS goods_num
        ,COUNT(p1.order_id) AS order_num
FROM zydb.dw_order_node_time AS p1
WHERE p1.order_status = 1
  AND p1.is_shiped = 1
  AND p1.depot_id = 7
  AND p1.shipping_time >= '2017-06-01'
  AND p1.shipping_time <  '2018-01-01'
  AND p1.goods_number >= 1
GROUP BY SUBSTR(p1.shipping_time, 1, 7)
        ,(CASE WHEN p1.goods_number <= 4 THEN '<=4'
               WHEN p1.goods_number = 5 THEN '=5'
               ELSE '>=6'
          END)
ORDER BY ship_month
;
-- 沙特仓平均出单件数 ===========================================================
WITH
-- 库存件数
t1 AS
(SELECT CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  ) AS stock_date
        ,SUM(p1.stock_num) AS total_stock_num
FROM zydb.ods_who_wms_goods_stock_detail AS p1
WHERE p1.depot_id = 7
GROUP BY CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  )
),
-- 销售件数
t2 AS
(SELECT SUBSTR(p1.shipping_time, 1, 10) AS ship_date
        ,SUM(p1.goods_number) AS total_goods_num
        ,AVG(p1.goods_number) AS avg_goods_num
FROM zydb.dw_order_node_time AS p1
WHERE p1.order_status = 1
  AND p1.is_shiped = 1
  AND p1.depot_id = 7
  AND p1.shipping_time >= '2017-06-01'
  AND p1.shipping_time <  '2018-01-01'
  AND p1.goods_number >= 1
GROUP BY SUBSTR(p1.shipping_time, 1, 10)
)
SELECT t2.*
        ,t1.total_stock_num
FROM t2
LEFT JOIN t1
       ON t2.ship_date = t1.stock_date
ORDER BY t2.ship_date
;


-- 沙特阿拉伯的订单，如果不拆单全部从沙特仓出，则为沙特仓整单命中；
-- 如果拆成沙特仓一单，国内仓一单，则沙特仓那一单为部分命中；
-- 那么先看沙特阿拉伯的所有母单的商品命中率是多少？
-- 再看国内子单的命中率是多少？

-- 什么会影响沙特仓的命中率？ -- 商品库存
-- 1. 宽度：类目结构，如某些类目缺失，导致类目太单一，降低命中率
-- 2. 深度：商品数量，如孤品太多，降低命中率降低  √
-- 3. 商品销售性质结构，如滞销品太多，降低命中率
-- 4. 丰富度：商品款数goods_id

-- extEND表:每天存全量订单，查询时，取最近一天data_date的数据

SELECT p1.*
FROM zydb.dw_order_fact_extEND AS p1
WHERE p1.COUNTry = 1876
  AND p1.pay_status IN (1, 3)
  AND p1.data_date = '20180208'
  AND p1.pay_time >= '2017-10-01'
  AND p1.pay_time <  '2018-02-01'
LIMIT 10;

SELECT SUBSTR(p1.pay_time, 1, 10) AS pay_date
        ,SUM(p1.org_goods_num) AS total_goods_num
        ,AVG(p1.org_goods_num) AS avg_goods_num
FROM zydb.dw_order_fact_extEND AS p1
WHERE p1.is_split = 1
  AND p1.COUNTry = 1876
  AND p1.pay_status IN (1, 3)
  AND p1.pay_time >= '2017-10-01'
  AND p1.pay_time <  '2018-02-01'
GROUP BY SUBSTR(p1.pay_time, 1, 10)
ORDER BY pay_date
;

-- 母单如何拆分到SA仓子单、CN仓子单，拆分中CN仓的是没有sku的情况多，还是sku数量不够多的情况多

WITH
-- 子母单
t1 AS
(SELECT p1.order_id
        ,SUBSTR(p1.pay_time, 1, 10) AS pay_date
        ,p1.org_goods_num AS mom_order_org_num
        ,p1.sa_org_goods_num
        ,p1.cn_org_goods_num
        ,(CASE WHEN p1.sa_order_id IS NOT NULL THEN p1.sa_order_id
               WHEN p1.sa_order_id IS NULL AND p1.sa_org_goods_num >= 1 THEN p1.order_id
               ELSE NULL
          END) AS sa_order_id
        ,(CASE WHEN p1.cn_order_id IS NOT NULL THEN p1.cn_order_id
               WHEN p1.cn_order_id IS NULL AND p1.cn_org_goods_num >= 1 THEN p1.order_id
               ELSE NULL
          END) AS cn_order_id
FROM zydb.dw_order_fact_extEND AS p1
WHERE p1.data_date = SUBSTR(REGEXP_REPLACE(TO_DATE(DATE_SUB(CURRENT_TIMESTAMP(), 1)), '-', ''), 1, 8)  --昨天数据
  AND p1.COUNTry = 1876  --沙特阿拉伯订单
  AND p1.pay_status IN (1, 3)
  AND p1.org_goods_num >= 1
  AND (p1.sa_org_goods_num >= 1 OR p1.cn_org_goods_num >= 1)
  AND p1.pay_time >= '2017-10-01'
  AND p1.pay_time <  '2017-11-01'
  --AND p1.order_id = 27093797
),
-- sku拆单明细
t2 AS
(SELECT t1.*
        ,p1.sku_id
        ,p1.original_goods_number AS mom_sku_org_num
        ,p2.original_goods_number AS sa_sku_org_num
        ,p3.original_goods_number AS cn_sku_org_num
FROM t1
LEFT JOIN zydb.dw_order_goods_fact AS p1
       ON t1.order_id = p1.order_id
LEFT JOIN zydb.dw_order_goods_fact AS p2
       ON t1.sa_order_id = p2.order_id
      AND p1.sku_id = p2.sku_id
LEFT JOIN zydb.dw_order_goods_fact AS p3
       ON t1.cn_order_id = p3.order_id
      AND p1.sku_id = p3.sku_id
)
SELECT COUNT(*) AS total_records
        ,SUM(t2.mom_sku_org_num) AS mom_sku_org_num
        ,SUM(t2.sa_sku_org_num) AS sa_sku_org_num
        ,SUM(t2.cn_sku_org_num) AS cn_sku_org_num
        ,SUM(CASE WHEN t2.sa_sku_org_num >= 1 AND t2.cn_sku_org_num >= 1 THEN 1 ELSE 0 END) AS sku_both_records
FROM t2
;

/*
    6732051 7440109 1288390 6174685 43078
-- 从上面的数字来看，孤品对命中率的影响不大，很少的比例(43078/6732051=0.6%)的sku出现沙特仓数量不够，从而同一个sku分别拆单到SA仓和CN仓
-- 数据有问题，还需要核实
*/


-- SA仓命中的商品与拆分到CN仓的商品，从类目结构上看，有什么差异吗？






-- CN三仓平均出单件数 ===========================================================
WITH
-- 库存件数
t1 AS
(SELECT CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  ) AS stock_date
        ,SUM(p1.stock_num) AS total_stock_num
FROM zydb.ods_who_wms_goods_stock_detail AS p1
WHERE p1.depot_id IN (4, 5, 6, 14)
GROUP BY CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  )
),
-- 销售件数
t2 AS
(SELECT SUBSTR(p1.shipping_time, 1, 10) AS ship_date
        ,SUM(p1.goods_number) AS total_goods_num
        ,AVG(p1.goods_number) AS avg_goods_num
FROM zydb.dw_order_node_time AS p1
WHERE p1.order_status = 1
  AND p1.is_shiped = 1
  AND p1.depot_id IN (4, 5, 6, 14)
  AND p1.shipping_time >= '2017-10-01'
  AND p1.shipping_time <  '2018-02-01'
  AND p1.goods_number >= 1
GROUP BY SUBSTR(p1.shipping_time, 1, 10)
)
SELECT t2.*
        ,t1.total_stock_num
FROM t2
LEFT JOIN t1
       ON t2.ship_date = t1.stock_date
ORDER BY t2.ship_date
;


-- daily数据，沙特阿拉伯母单分拆到SA仓和CN仓 ======================================
WITH
-- 沙特阿拉伯母单信息
t1 AS
(SELECT SUBSTR(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END, 1, 10) AS pay_date
        ,COUNT(p1.order_id) AS mom_order_num
        ,SUM(p1.original_goods_number) AS mom_org_goods_num
        ,SUM(p1.goods_number) AS mom_goods_num
        ,AVG(p1.original_goods_number) AS avg_mom_org_goods_num
        ,AVG(p1.goods_number) AS avg_mom_goods_num
FROM zydb.dw_order_fact AS p1
WHERE p1.country_name = 'United Arab Emirates' = 'Saudi Arabia'
  AND p1.pay_status IN (1, 3)
  AND (CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END) >= '2017-10-01'
  AND (CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END) <  '2018-02-01'
GROUP BY SUBSTR(CASE WHEN p1.pay_id = 41 THEN p1.pay_time ELSE p1.result_pay_time END, 1, 10)
--ORDER BY pay_date
--LIMIT 10
),
-- 库存件数
-- SA库存件数
t201 AS
(SELECT CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  ) AS stock_date
        ,SUM(CASE WHEN p1.depot_id = 7 THEN p1.stock_num ELSE 0 END) AS sa_stock_num    --库存件数
        ,COUNT(DISTINCT CASE WHEN p1.depot_id = 7 THEN p1.goods_id ELSE NULL END) AS sa_goods_COUNT    --库存goods数
        ,SUM(CASE WHEN p1.depot_id = 7 THEN 1 ELSE 0 END) AS sa_sku_COUNT    --库存sku数
FROM zydb.ods_who_wms_goods_stock_detail AS p1
WHERE p1.stock_num >= 1
GROUP BY CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  )
),
-- CN库存件数
t202 AS
(SELECT CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  ) AS stock_date
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN p1.stock_num ELSE 0 END) AS cn_stock_num    --库存件数
        ,COUNT(DISTINCT CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN p1.goods_id ELSE NULL END) AS cn_goods_COUNT    --库存goods数
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN 1 ELSE 0 END) AS cn_sku_COUNT    --库存sku数
FROM zydb.ods_who_wms_goods_stock_detail AS p1
WHERE p1.stock_num >= 1
GROUP BY CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  )
),
-- 销售单数和件数
t3 AS
(SELECT SUBSTR(p1.pay_time, 1, 10) AS pay_date
        ,SUM(CASE WHEN p1.depot_id = 7 THEN 1 ELSE 0 END) AS sa_order_num
        ,SUM(CASE WHEN p1.depot_id = 7 THEN p1.goods_number ELSE 0 END) AS sa_sale_goods_num
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN 1 ELSE 0 END) AS cn_order_num
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN p1.goods_number ELSE 0 END) AS cn_sale_goods_num
FROM zydb.dw_order_node_time AS p1
WHERE p1.order_status = 1
  AND p1.pay_status IN (1, 3)
  AND p1.country_name = 'United Arab Emirates' = 'Saudi Arabia'
  AND p1.pay_time >= '2017-10-01'
  AND p1.pay_time <  '2018-02-01'
GROUP BY SUBSTR(p1.pay_time, 1, 10)
),
-- CN仓命中商品数
t4 AS
(SELECT SUBSTR(p1.pay_time, 1, 10) AS pay_date
        ,SUM(CASE WHEN p3.order_id IS NULL THEN p2.original_goods_number ELSE 0 END) AS aim_goods_num
FROM zydb.dw_order_node_time AS p1
LEFT JOIN zydb.dw_order_goods_fact AS p2
       ON p1.order_id = p2.order_id
LEFT JOIN (SELECT DISTINCT rec_id, order_id, goods_id FROM zydb.dw_demAND_pur) AS p3
       ON p2.order_id = p3.order_id
      AND p2.goods_id = p3.goods_id
WHERE p1.order_status = 1
  AND p1.pay_status IN (1, 3)
  AND p1.depot_id IN (4, 5, 6, 14)
  AND p1.country_name = 'United Arab Emirates' = 'Saudi Arabia'
  AND p1.pay_time >= '2017-10-01'
  AND p1.pay_time <  '2018-02-01'
GROUP BY SUBSTR(p1.pay_time, 1, 10)
)
-- 结果表
SELECT t1.*
        ,t201.sa_stock_num
        ,t201.sa_goods_COUNT
        ,t201.sa_sku_COUNT
        ,t202.cn_stock_num
        ,t202.cn_goods_COUNT
        ,t202.cn_sku_COUNT
        ,t3.sa_order_num
        ,t3.sa_sale_goods_num
        ,t3.cn_order_num
        ,t3.cn_sale_goods_num
        ,t4.aim_goods_num
FROM t1
LEFT JOIN t201
       ON t1.pay_date = t201.stock_date
LEFT JOIN t202
       ON t1.pay_date = t202.stock_date
LEFT JOIN t3
       ON t1.pay_date = t3.pay_date
LEFT JOIN t4
       ON t1.pay_date = t4.pay_date
ORDER BY t1.pay_date
;


-- 1.沙特阿拉伯销售类目结构
--   SA仓出单商品类目结构
--   CN仓出单商品类目结构
--   SA仓库存商品类目结构
--   CN仓库存商品类目结构

WITH
-- 销售类目结构
t1 AS
(SELECT SUBSTR(p1.pay_time, 1, 10) AS pay_date
        ,p3.cate_level1_name
        ,p3.cate_level2_name
        ,SUM(p2.goods_number) AS total_goods_num
        ,SUM(CASE WHEN p1.depot_id = 7 THEN p2.goods_number ELSE 0 END) AS sa_sale_goods_num
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN p2.goods_number ELSE 0 END) AS cn_sale_goods_num
FROM zydb.dw_order_node_time AS p1
LEFT JOIN zydb.dw_order_goods_fact AS p2
       ON p1.order_id = p2.order_id
LEFT JOIN zydb.dim_goods AS p3
       ON p2.goods_id = p3.goods_id
WHERE p1.order_status = 1
  AND p1.pay_status IN (1, 3)
  AND p1.country_name = 'United Arab Emirates' = 'Saudi Arabia'
  AND p1.pay_time >= '2017-10-01'
  AND p1.pay_time <  '2018-02-01'
GROUP BY SUBSTR(p1.pay_time, 1, 10)
        ,p3.cate_level1_name
        ,p3.cate_level2_name
),
-- 库存类目结构
t2 AS
(SELECT CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  ) AS stock_date
        ,p2.cate_level1_name
        ,p2.cate_level2_name
        ,SUM(CASE WHEN p1.depot_id = 7 THEN p1.stock_num ELSE 0 END) AS sa_stock_num
        ,SUM(CASE WHEN p1.depot_id = 7 THEN 1 ELSE 0 END) AS sa_sku_COUNT
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN p1.stock_num ELSE 0 END) AS cn_stock_num
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN 1 ELSE 0 END) AS cn_sku_COUNT
FROM zydb.ods_who_wms_goods_stock_detail AS p1
LEFT JOIN zydb.dim_goods AS p2
       ON p1.goods_id = p2.goods_id
WHERE p1.data_date >= '20171001'
  AND p1.data_date <  '20180201'
  AND p1.stock_num >= 1
GROUP BY CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  )
        ,p2.cate_level1_name
        ,p2.cate_level2_name
)
--结果
SELECT COALESCE(t1.pay_date, t2.stock_date) AS data_date
        ,COALESCE(t1.cate_level1_name, t2.cate_level1_name) AS cat_level1_name
        ,COALESCE(t1.cate_level2_name, t2.cate_level2_name) AS cat_level2_name
        ,t1.total_goods_num
        ,t1.sa_sale_goods_num
        ,t1.cn_sale_goods_num
        ,t2.sa_stock_num
        ,t2.cn_stock_num
FROM t1
FULL OUTER JOIN t2
             ON t1.pay_date = t2.stock_date
            AND t1.cate_level1_name = t2.cate_level1_name
            AND t1.cate_level2_name = t2.cate_level2_name
ORDER BY data_date
        ,cat_level1_name
        ,cat_level2_name
;


SELECT *
FROM t1
LIMIT 10;


-- 2.SA仓库存商品件数结构
--   CN仓库存商品件数结构
-- 到sku_id
WITH
t1 AS
(SELECT CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  ) AS stock_date
        ,(CASE WHEN p1.stock_num >= 6 THEN 6 ELSE p1.stock_num END) AS stock_num_level
        ,SUM(CASE WHEN p1.depot_id = 7 THEN p1.stock_num ELSE 0 END) AS sa_sku_num
        ,SUM(CASE WHEN p1.depot_id = 7 THEN 1 ELSE NULL END) AS sa_sku_COUNT
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN p1.stock_num ELSE 0 END) AS cn_sku_num
        ,SUM(CASE WHEN p1.depot_id IN (4, 5, 6, 14) THEN 1 ELSE NULL END) AS cn_sku_COUNT
FROM zydb.ods_who_wms_goods_stock_detail AS p1
WHERE p1.data_date >= '20171001'
  AND p1.data_date <  '20180201'
  AND p1.stock_num >= 1
GROUP BY CONCAT_WS('-',
                  SUBSTR(p1.data_date, 1, 4),
                  SUBSTR(p1.data_date, 5, 2),
                  SUBSTR(p1.data_date, 7, 2)
                  )
        ,(CASE WHEN p1.stock_num >= 6 THEN 6 ELSE p1.stock_num END)
)
SELECT *
FROM t1
ORDER BY stock_date
        ,stock_num_level
;


-- 3.SA仓库存商品销售性质结构
--   CN仓库存商品销售性质结构
-- 执御的商品销售性质不合理，销售性质与库存结合在一起了，特别是滞销




-- HK仓整单命中订单比例
WITH
-- 下单数
t1 AS
(SELECT TO_DATE(p1.pay_time) AS pay_date
        ,COUNT(p1.order_id) AS order_num
FROM zydb.dw_order_node_time AS p1
WHERE p1.order_status = 1
  AND p1.pay_status IN (1, 3)
  AND p1.depot_id = 6
GROUP BY TO_DATE(p1.pay_time)
),
-- 订单命中数
t2 AS
(SELECT TO_DATE(CASE WHEN pay_id=41 THEN a.pay_time ELSE result_pay_time END) AS data_date
        ,a.order_id AS all_order_id
        ,b.order_id AS pur_order_id
FROM zydb.dw_order_sub_order_fact AS a
LEFT JOIN (SELECT DISTINCT rec_id,order_id FROM zydb.dw_demAND_pur) AS b
       ON a.order_id = b.order_id
WHERE TO_DATE(CASE WHEN pay_id=41 THEN a.pay_time ELSE result_pay_time END) >= TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${data_date}','yyyyMMdd')))
  AND a.depod_id = 6
)
SELECT data_date
        ,SUM(CASE WHEN pur_order_id IS NULL THEN 1 ELSE 0 END) hit_rate_order
FROM t1
GROUP BY data_date
ORDER BY data_date
;


-- 自由库存、可售件数和款数、出入库量 ==============================================
WITH
-- 1.出入库量
t1 AS
(SELECT FROM_UNIXTIME(t1.change_time, 'yyyy-MM-dd') AS data_date
        ,SUM(CASE WHEN t1.change_type IN (1,2,3,4,9,11,14,15,16) THEN t1.change_num ELSE 0 END) AS INstock_num
        ,SUM(CASE WHEN t1.change_type IN (5,6,13,17) THEN t1.change_num ELSE 0 END) AS outstock_num
FROM jolly_wms.who_wms_goods_stock_detail_log AS t1
WHERE t1.change_time >= UNIX_TIMESTAMP('2018-02-09')
  AND t1.depot_id = 15
GROUP BY FROM_UNIXTIME(t1.change_time, 'yyyy-MM-dd')
),
-- 2.自由库存件数、可售件数和款数
t2 AS
(SELECT t1.data_date
        ,SUM(t1.free_num_dubai) AS free_num
        ,SUM(CASE WHEN t1.free_num_dubai >= 1 THEN 1 ELSE 0 END) AS free_goods_COUNT
        ,SUM(t1.can_sale_num_dubai) AS can_sale_num
        ,SUM(CASE WHEN t1.can_sale_num_dubai >= 1 THEN 1 ELSE 0 END) AS can_sale_goods_COUNT
FROM zybiro.blue_uae_goods_detail_partition AS t1
WHERE t1.data_date >= '2018-02-09'
GROUP BY t1.data_date
)
SELECT t2.*
        ,t1.instock_num
        ,t1.outstock_num
FROM t2
LEFT JOIN t1 ON t1.data_date = t2.data_date
ORDER BY t2.data_date
;


-- 订单结构 =====================================================================
WITH
-- 1.United Arab Emirates的所有母单
t1 AS
(SELECT t1.add_time
        ,t1.order_id
        ,t1.is_split
        ,t1.pay_status
FROM zydb.dw_order_fact AS t1
WHERE t1.country_name = 'United Arab Emirates'='United Arab Emirates'
  AND t1.site_id IN (600,900)
  AND t1.add_time >= '2018-02-09'
),
-- 2.order_user_info
t2 AS
(SELECT t1.depot_coverage_area_id
        ,t1.source_order_id
        ,t1.order_id
FROM jolly.who_order_user_info AS t1
UNION
SELECT t2.depot_coverage_area_id
        ,t2.source_order_id
        ,t2.order_id
FROM jolly.who_order_user_info_history AS t2
),
-- 3.汇总每一天的订单结构
t3 AS
(SELECT TO_DATE(t1.add_time) AS data_date
        ,SUM(CASE WHEN t1.order_id IS NOT NULL THEN 1 ELSE 0 END) AS total_add_order_num
        ,SUM(CASE WHEN t2.depot_coverage_area_id = 12 AND t2.source_order_id = 0 AND t1.is_split IS NULL THEN 1 ELSE 0 END) AS dubai_add_order_num
        ,SUM(CASE WHEN t2.depot_coverage_area_id = 1 AND t2.source_order_id = 0 AND t1.is_split IS NULL THEN 1 ELSE 0 END) AS cn_add_order_num
        ,SUM(CASE WHEN t1.is_split = 1 THEN 1 ELSE 0 END) AS mix_add_order_num
        ,SUM(CASE WHEN t1.pay_status IN (1,3) THEN 1 ELSE 0 END) AS total_pay_order_num
        ,SUM(CASE WHEN t1.pay_status IN (1,3) AND t2.depot_coverage_area_id = 12 AND t2.source_order_id = 0 AND t1.is_split IS NULL THEN 1 ELSE 0 END) AS dubai_pay_order_num
        ,SUM(CASE WHEN t1.pay_status IN (1,3) AND t2.depot_coverage_area_id = 1 AND t2.source_order_id = 0 AND t1.is_split IS NULL THEN 1 ELSE 0 END) AS cn_pay_order_num
        ,SUM(CASE WHEN t1.pay_status IN (1,3) AND t1.is_split = 1 THEN 1 ELSE 0 END) AS mix_pay_order_num
FROM t1
LEFT JOIN t2
       ON t1.order_id = t2.order_id
GROUP BY TO_DATE(t1.add_time)
)
-- 4.结果，计算付款率和订单结构占比
SELECT t3.*
        ,decode(t3.total_pay_order_num, 0, 0, t3.dubai_pay_order_num/t3.total_pay_order_num) AS dubai_paid_orders_ratio
        ,decode(t3.total_pay_order_num, 0, 0, t3.cn_pay_order_num/t3.total_pay_order_num) AS cn_paid_orders_ratio
        ,decode(t3.total_pay_order_num, 0, 0, t3.mix_pay_order_num/t3.total_pay_order_num) AS mix_paid_orders_ratio
        ,decode(t3.total_add_order_num, 0, 0, t3.total_pay_order_num/t3.total_add_order_num) AS order_paid_rate
        ,decode(t3.dubai_add_order_num, 0, 0, t3.dubai_pay_order_num/t3.dubai_add_order_num) AS dubai_order_paid_rate
        ,decode(t3.cn_add_order_num, 0, 0, t3.cn_pay_order_num/t3.cn_add_order_num) AS cn_order_paid_rate
        ,decode(t3.mix_add_order_num, 0, 0, t3.mix_pay_order_num/t3.mix_add_order_num) AS mix_order_paid_rate
FROM t3
ORDER BY t3.data_date
;


-- 销售额，客单价，笔单价 ========================================================
-- hive
SELECT TO_DATE(CASE WHEN t1.pay_id=41 THEN t1.pay_time ELSE t1.result_pay_time END) AS data_date
        ,SUM(t1.order_amount_no_bonus)  AS order_amount_no_bonus     --销售额
        ,SUM(t1.goods_number) AS goods_num
        ,COUNT(DISTINCT t1.user_id) AS paid_user_num                    --购买用户数
        ,COUNT(DISTINCT t1.order_id) AS paid_order_num              --付款订单数
        ,SUM(t1.order_amount_no_bonus)/COUNT(DISTINCT t1.user_id ) AS avg_user_price              --客单价
        ,SUM(t1.order_amount_no_bonus)/COUNT(DISTINCT t1.order_id) AS avg_order_price             --笔单价
FROM zydb.dw_order_fact AS t1
WHERE t1.pay_status IN (1,3)
  AND t1.site_id IN (400,700,600,601,800,900)
  AND t1.country_name = 'United Arab Emirates'
  AND TO_DATE(CASE WHEN t1.pay_id=41 THEN t1.pay_time ELSE t1.result_pay_time END) >= '2018-02-09'
GROUP BY TO_DATE(CASE WHEN t1.pay_id=41 THEN t1.pay_time ELSE t1.result_pay_time END)
ORDER BY data_date
;



-- 沙特订单付款率
SELECT t1.data_date
        ,t1.order_paid_rate
        ,t1.sa_order_paid_rate
        ,t1.cn_order_paid_rate
        ,t1.mix_order_paid_rate
FROM zydb.rpt_sa_warehouse_report AS t1
ORDER BY t1.data_date
LIMIT 100;


-- 问题单时间 ===================================================================

-- case1: if 标问题单时间<打包完成时间<问题单标非时间<发货时间,则影响时长=问题单标非时间-打包完成时间
-- case2: if 打包完成时间<标问题单时间<问题单标非时间<发货时间,则影响时长=问题单标非时间-标问题单时间
-- case3: if 标问题单时间<问题单标非时间<打包完成时间<发货时间,则影响时长=0
WITH
t1 AS
(SELECT SUBSTR(shipping_time, 1, 10) AS ship_date
        ,COUNT(*) AS total_order_num
        ,SUM(UNIX_TIMESTAMP(t1.shipping_time) - UNIX_TIMESTAMP(t1.order_pack_time))/COUNT(*)/3600 AS avg_ship_hour
        ,SUM(UNIX_TIMESTAMP(t1.shipping_time) - UNIX_TIMESTAMP(t1.order_pack_time))/3600 AS total_ship_hour
        ,SUM(CASE WHEN t1.problems_order_uptime < t1.order_pack_time AND t1.order_pack_time < t1.no_problems_order_uptime
                  THEN 1
                  ELSE 0
             END) AS case1_order_num
        ,SUM(CASE WHEN t1.problems_order_uptime < t1.order_pack_time AND t1.order_pack_time < t1.no_problems_order_uptime
                  THEN (UNIX_TIMESTAMP(t1.no_problems_order_uptime) - UNIX_TIMESTAMP(t1.order_pack_time))/3600
                  ELSE 0
             END) AS case1_duoyu_hour
        ,SUM(CASE WHEN t1.order_pack_time < t1.problems_order_uptime AND t1.problems_order_uptime < t1.no_problems_order_uptime
                  THEN 1
                  ELSE 0
             END) AS case2_order_num
        ,SUM(CASE WHEN t1.order_pack_time < t1.problems_order_uptime AND t1.problems_order_uptime < t1.no_problems_order_uptime
                  THEN (UNIX_TIMESTAMP(t1.no_problems_order_uptime) - UNIX_TIMESTAMP(t1.problems_order_uptime))/3600
                  ELSE 0
             END) AS case2_duoyu_hour
        ,SUM(CASE WHEN t1.problems_order_uptime < t1.no_problems_order_uptime AND t1.no_problems_order_uptime < t1.order_pack_time
                  THEN 1
                  ELSE 0
             END) AS case3_order_num
FROM zydb.dw_order_node_time AS t1
WHERE t1.is_shiped = 1
  AND t1.shipping_time >= '2018-01-01'
  AND t1.shipping_time <  '2018-02-28'
  AND t1.order_pack_time IS NOT NULL
  AND t1.problems_order_uptime IS NOT NULL
  AND t1.no_problems_order_uptime IS NOT NULL
GROUP BY SUBSTR(shipping_time, 1, 10)
)
SELECT *
FROM t1
ORDER BY ship_date DESC
;


/*
-- 智能补货平台：补货提前期参数设置 ===============================================
补货提前期LT
√ 订单反应时长：LT0(订单反应时长)：是指已签收商品从客户下单付款至采购订单推送至商家的时间
√ 商家备货时长：供应商备货时长：从采购需求推送到供应商至供应商发货的时长
√ 国内运输时长：供应商发货至仓库签收的时长
√ 国内仓操作时长：LT2(仓库作业时长)：是指已发货包裹从商品签收至货品分拣直至包裹可提货状态的时间
× 国际运输时长(Sea)
× 国际运输时长(Air)
× 国际通关时长
× 本地运输时长
× 海外仓操作时长：备货目的仓的质检上架时长，个人认为不需要，这个时长比较短，可忽略。
*/

WITH
-- 1.订单反应时长、商家备货时长、国内运输时长
t1 AS
(SELECT SUBSTR(p1.order_pay_date, 1, 7) AS data_month
        ,SUM((UNIX_TIMESTAMP(p1.demand_push_time) - UNIX_TIMESTAMP(p1.order_pay_time))/3600) / SUM(p1.goods_number) AS lt0_order_response_time
        ,SUM((UNIX_TIMESTAMP(p1.pur_send_time) - UNIX_TIMESTAMP(p1.demand_push_time))/3600) / SUM(p1.send_num) AS supp_prepare_time
        ,SUM((UNIX_TIMESTAMP(p1.receipt_time) - UNIX_TIMESTAMP(p1.pur_send_time))/3600) / SUM(p1.send_num) AS country_ship_time
FROM zybiro.neo_pur_lock_detail AS p1
WHERE p1.depot_id IN (4, 5, 14)
  AND p1.order_pay_date < '2018-01-09'
GROUP BY SUBSTR(p1.order_pay_date, 1, 7)
)
SELECT *
FROM t1
ORDER BY data_month
;


-- 智能补货平台：补货提前期参数设置 ===============================================

-- 仓储：每月出入库平均时长
-- 20171024-20171104这一段时间，打包时长异常，出库时长重新取值
WITH
-- 1.入库时效
t1 AS
(SELECT SUBSTR(CAST(t1.data_date AS STRING), 1, 6) AS data_month
        ,AVG(t1.receipt_quality_duration) AS qc_duration
        ,AVG(t1.quality_onshelf_duration) AS onshelf_duration
        ,AVG(t1.receipt_onself_duration) AS in_wh_duration
FROM zydb.rpt_depot_daily_report_new AS t1
WHERE t1.depot_id IN (5, 14)
GROUP BY SUBSTR(CAST(t1.data_date AS STRING), 1, 6)
),
-- 2.出库时效
t2 AS
(SELECT SUBSTR(REGEXP_REPLACE(t1.shipping_time, '-', ''), 1, 6) AS data_month
        ,AVG((UNIX_TIMESTAMP(t1.picking_finish_time) - UNIX_TIMESTAMP(t1.outing_stock_time))/3600) AS pick_duration
        ,AVG((UNIX_TIMESTAMP(t1.order_pack_time) - UNIX_TIMESTAMP(t1.picking_finish_time))/3600) AS pack_duration
        ,AVG((UNIX_TIMESTAMP(t1.shipping_time) - UNIX_TIMESTAMP(t1.order_pack_time))/3600) AS ship_duration
FROM zydb.dw_order_node_time AS t1
WHERE t1.depot_id IN (5, 14)
GROUP BY SUBSTR(REGEXP_REPLACE(t1.shipping_time, '-', ''), 1, 6)
)
-- 结果，汇总
SELECT t1.*
        ,t2.pick_duration
        ,t2.pack_duration
        ,t2.ship_duration
        ,(t2.pick_duration + t2.pack_duration + t2.ship_duration) AS out_wh_duration
FROM t1
LEFT JOIN t2 ON t1.data_month = t2.data_month
ORDER BY t1.data_month
;


-- 到货签收的状态和时间不一致
SELECT a.depot_id
        ,a.pur_order_id
        ,a.pur_order_sn
        ,FROM_UNIXTIME(a.gmt_created) AS create_time
        ,FROM_UNIXTIME(a.send_time) AS send_time
        ,a.check_status
        ,c.end_receipt_time
FROM jolly_spm.jolly_spm_pur_order_info AS a
FULL JOIN zydb.dw_delivered_order_info c
       ON a.pur_order_sn = c.delivered_order_sn
WHERE c.end_receipt_time IS NULL
  AND a.depot_id = 4
  AND a.send_time >= UNIX_TIMESTAMP('2018-01-01')
  AND a.send_time <  UNIX_TIMESTAMP('2018-03-04')
LIMIT 100
;

-- 智能补货
-- 提货单：手工录入各个节点的处理时间，需开发提供数据字典
-- 包裹号与箱号会关联吗？


-- 部分订单的签收人、是否首单、是否签收
-- 注意：用hive跑
SELECT p1.order_sn
        ,p3.consignee
        ,(CASE WHEN p3.is_first_order = 0 THEN '否' ELSE '是' END) AS is_first_order
        ,p2.order_status
        ,(CASE WHEN p4.shipping_state = 3 THEN '已签收' ELSE '其他' END) AS is_qianshou
FROM zybiro.neo_wangjie_order_sn AS p1
LEFT JOIN dw.dw_order_sub_order_fact AS p2
       ON p1.order_sn = p2.order_sn
LEFT JOIN jolly.who_order_user_info AS p3
       ON p2.order_id = p3.order_id
LEFT JOIN jolly.who_order_shipping_tracking AS p4
       ON p2.order_id = p4.order_id
;



-- 海外备货商品的属性
-- 把sku列表导入到zybiro.stephen_oversea_sale_prediction表中
SELECT p1.*
        ,p2.goods_id
        ,p3.cate_level1_name
        ,p3.cate_level2_name
        ,p3.supp_name
        ,(CASE WHEN p3.goods_season = 1 THEN '春'
               WHEN p3.goods_season = 2 THEN '夏'
               WHEN p3.goods_season = 3 THEN '秋'
               WHEN p3.goods_season = 4 THEN '冬'
               WHEN p3.goods_season = 5 THEN '春夏'
               WHEN p3.goods_season = 6 THEN '春秋'
               WHEN p3.goods_season = 7 THEN '春冬'
               WHEN p3.goods_season = 8 THEN '夏秋'
               WHEN p3.goods_season = 9 THEN '夏冬'
               WHEN p3.goods_season = 10 THEN '秋冬'
               ELSE '其他'
          END) AS good_season
FROM zybiro.stephen_oversea_sale_prediction AS p1
LEFT JOIN jolly.who_sku_relation p2
       ON p1.sku_id = p2.rec_id
LEFT JOIN zydb.dim_goods p3
       ON p2.goods_id = p3.goods_id
;


SELECT SUM(p2.goods_number) AS sale_goods_num
        ,SUM(p2.goods_number * p3.in_price) AS in_amount
        ,SUM(p2.goods_number * p3.shop_price) AS sale_amount
FROM dw.dw_order_node_time AS p1
LEFT JOIN dw.dw_order_goods_fact AS p2
       ON p1.order_id = p2.order_id
LEFT JOIN jolly.who_goods AS p3
       ON p2.goods_id = p3.goods_id
WHERE p1.order_status = 1
  AND p1.pay_status IN (1, 3)
  AND p3.provider_code = '3C8'
;


SELECT *
FROM jolly.who_wms_on_shelf_info AS p1
WHERE p1.check_sn IS NOT NULL
ORDER BY p1.gmt_created DESC
LIMIT 10;