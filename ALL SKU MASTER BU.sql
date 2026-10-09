WITH product_tags_raw AS (
    SELECT
        ti.object_id AS product_id,
        tag.name AS tag_name
    FROM taggit_taggeditem ti
    JOIN taggit_tag tag
        ON ti.tag_id = tag.id
),
product_tags AS (
    SELECT
        product_id,
        STRING_AGG(
            DISTINCT CASE
                WHEN UPPER(tag_name) LIKE 'DIVISION_%'
                THEN split_part(tag_name, '_', 2)
            END,
            '/' ORDER BY
            CASE
                WHEN UPPER(tag_name) LIKE 'DIVISION_%'
                THEN split_part(tag_name, '_', 2)
            END
        ) AS division,
        STRING_AGG(
            DISTINCT CASE
                WHEN UPPER(tag_name) LIKE 'FASHIONSTYLE_%'
                THEN split_part(tag_name, '_', 2)
            END,
            '/' ORDER BY
            CASE
                WHEN UPPER(tag_name) LIKE 'FASHIONSTYLE_%'
                THEN split_part(tag_name, '_', 2)
            END
        ) AS fashion_style,
        STRING_AGG(
            DISTINCT CASE
                WHEN UPPER(tag_name) LIKE 'CATEGORY_%'
                THEN split_part(tag_name, '_', 2)
            END,
            '/' ORDER BY
            CASE
                WHEN UPPER(tag_name) LIKE 'CATEGORY_%'
                THEN split_part(tag_name, '_', 2)
            END
        ) AS category,
        STRING_AGG(
            DISTINCT CASE
                WHEN UPPER(tag_name) LIKE 'SUBCATEGORY_%'
                THEN split_part(tag_name, '_', 2)
            END,
            '/' ORDER BY
            CASE
                WHEN UPPER(tag_name) LIKE 'SUBCATEGORY_%'
                THEN split_part(tag_name, '_', 2)
            END
        ) AS subcategory,
        STRING_AGG(
            DISTINCT CASE
                WHEN UPPER(tag_name) LIKE 'PRODUCTTYPE_%'
                THEN split_part(tag_name, '_', 2)
            END,
            '/' ORDER BY
            CASE
                WHEN UPPER(tag_name) LIKE 'PRODUCTTYPE_%'
                THEN split_part(tag_name, '_', 2)
            END
        ) AS product_type,
        STRING_AGG(
            DISTINCT CASE
                WHEN UPPER(tag_name) LIKE 'GENDER_%'
                THEN split_part(tag_name, '_', 2)
            END,
            '/' ORDER BY
            CASE
                WHEN UPPER(tag_name) LIKE 'GENDER_%'
                THEN split_part(tag_name, '_', 2)
            END
        ) AS gender,
        STRING_AGG(
            DISTINCT CASE
                WHEN UPPER(tag_name) LIKE 'ARTICLE TYPE_%'
                THEN split_part(tag_name, '_', 2)
            END,
            '/' ORDER BY
            CASE
                WHEN UPPER(tag_name) LIKE 'ARTICLE TYPE_%'
                THEN split_part(tag_name, '_', 2)
            END
        ) AS article_type
    FROM product_tags_raw
    GROUP BY product_id
),
sku_master AS (
    SELECT
        pp.id AS product_id,
        pp.sku,
        pp.skid,
        pp.variant_id AS style_code,
        pp.name AS product_name,
        LOWER(TRIM(pb.name)) AS brand,
        pt.division,
        pt.fashion_style,
        pt.category,
        pt.subcategory,
        pt.product_type,
        pt.gender,
        pt.article_type,
        sc.code AS company_code
    FROM product_product pp
    LEFT JOIN product_brand pb
        ON pb.id = pp.brand_id
    LEFT JOIN product_tags pt
        ON pt.product_id = pp.id
    LEFT JOIN store_company sc
        ON sc.id = pp.company_id
),
final AS (
    SELECT
        product_id,
        sku,
        skid,
        style_code,
        product_name,
        brand,
        company_code,
        division,
        fashion_style,
        category,
        subcategory,
        product_type,
        gender,
        article_type,

        CASE
            WHEN LOWER(TRIM(division)) = 'jewellery'
              OR LOWER(TRIM(category)) IN (
                    'men''s jewellery',
                    'women''s jewellery',
                    'men''s jewellery/women''s jewellery',
                    'body jewellery'
                 )
              OR LOWER(TRIM(subcategory)) IN (
                    'hair accessories'
                 )
              OR LOWER(TRIM(brand)) in ('ideaz')
            THEN 'JEWELLERY'

            WHEN LOWER(TRIM(subcategory)) IN (
                'bags & backpacks',
                'belts',
                'wallets',
                'caps & hats',
                'duffel bags',
                'eyewear',
                'handbags & wallets',
                'rucksacks',
                'sling & crossbody',
                'trolley bags',
                'watches',
                'travel organisers',
                'umbrellas',
                'raincoats',
                'passport holders',
                'socks',
                'neck pillows & eye masks',
                'fashion accessories'
            )
            OR LOWER(TRIM(brand)) in ('ensac','mokobara','fargo','lavie signature','wiki')
            THEN 'LTA'

            WHEN LOWER(TRIM(fashion_style)) = 'footwear'
            THEN 'FOOTWEAR'

            WHEN LOWER(TRIM(fashion_style)) = 'home & living'
            OR LOWER(TRIM(brand)) in ('home sizzler','fashion string')
            THEN 'HOME'

            WHEN LOWER(TRIM(fashion_style)) = 'ethnic'
            OR LOWER(TRIM(brand)) in ('fiorra','satrani','skylee','slikk x patola')
            THEN 'ETHNIC'

            WHEN LOWER(TRIM(fashion_style)) = 'western'
              OR LOWER(TRIM(brand)) IN (
                    'uptownie',
                    'brownbutter',
                    'bonkers corner'
                 )
              OR LOWER(TRIM(subcategory)) IN (
                    'pant sets',
                    'maxi',
                    'tops',
                    'skirts',
                    'skirt sets'
                 )
            THEN 'WESTERN'

            WHEN LOWER(TRIM(fashion_style)) = 'beauty'
              OR LOWER(TRIM(subcategory)) IN (
                    'gift sets',
                    'perfume',
                    'lips',
                    'face'
                 )
              OR LOWER(TRIM(brand)) IN (
                    'kimirica',
                    'la french'
                 )
            THEN 'BEAUTY'

            ELSE 'OTHERS'
        END AS master_bu
    FROM sku_master
)
SELECT
    sku,
    brand,
    company_code,
    fashion_style,
    division,
    category,
    subcategory,
    product_type,
    gender,
    article_type,
    style_code,
    product_name,
    skid,
    master_bu

FROM final
ORDER BY
    master_bu,
    brand,
    sku;

