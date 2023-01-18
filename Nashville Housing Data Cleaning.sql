Use Nashville

--Data Cleaning
SELECT * 
FROM Nashville_Housing

---------------Change Date format ---------
SELECT saledateconverted, CONVERT(date,saledate)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD saledateconverted Date;

UPDATE Nashville_Housing
SET saledateconverted = CONVERT(date,saledate)

ALTER TABLE Nashville_Housing
DROP COLUMN  saledate

--------------  Populate Property Adress Data ---------------------
SELECT *
FROM Nashville_Housing
--WHERE PROPERTYADDRESS IS NULL
ORDER BY PARCELID

SELECT NHA.parcelid, NHA.propertyaddress, 
NHB.parcelid, NHB.propertyaddress,
ISNULL(NHA.propertyaddress, NHB.propertyaddress)
FROM Nashville_Housing AS NHA
JOIN Nashville_Housing AS NHB
	ON NHA.parcelid = NHB.parcelid
	AND NHA.uniqueid <> NHB.uniqueid
WHERE NHA.propertyaddress IS NULL

UPDATE NHA
SET propertyaddress = ISNULL(NHA.propertyaddress, NHB.propertyaddress)
FROM Nashville_Housing AS NHA
JOIN Nashville_Housing AS NHB
	ON NHA.parcelid = NHB.parcelid
	AND NHA.uniqueid <> NHB.uniqueid
WHERE NHA.propertyaddress IS NULL

------Breaking out Address into Inddividual Columns --------
SELECT *
FROM Nashville_Housing
--WHERE PROPERTYADDRESS IS NULL
--ORDER BY PARCELID

SELECT 
SUBSTRING(propertyaddress,1, CHARINDEX(',',propertyaddress)-1) AS address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress))  AS address
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD propertysplitaddress nvarchar(255);

UPDATE Nashville_Housing
SET propertysplitaddress = SUBSTRING(propertyaddress,1, CHARINDEX(',',propertyaddress)-1)

ALTER TABLE Nashville_Housing
ADD propertysplitcity  Nvarchar(255)

UPDATE Nashville_Housing
SET propertysplitcity  = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress)


SELECT owneraddress
FROM Nashville_housing

SELECT
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM Nashville_housing


ALTER TABLE Nashville_Housing
ADD ownersplitaddress nvarchar(255);

UPDATE Nashville_Housing
SET ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE Nashville_Housing
ADD ownersplitcity  Nvarchar(255)

UPDATE Nashville_Housing
SET ownersplitcity  = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE Nashville_Housing
ADD ownersplitstate nvarchar(255);

UPDATE Nashville_Housing
SET ownersplitstate = PARSENAME(REPLACE(owneraddress,',','.'),1)

-------Change Y and N to Yes and No in 'Sold as Vacant'---------
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM Nashville_Housing
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END
FROM Nashville_Housing

UPDATE Nashville_Housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END
	
--------- Remove Duplicate Values-------------------
WITH ROWNUMCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledateconverted,
				 legalreference
				 ORDER BY
					Uniqueid) row_num
FROM Nashville_Housing
--ORDER BY parcelid
)
SELECT *
FROM ROWNUMCTE
WHERE row_num > 1
--ORDER BY propertyaddress


------------ DELETE UNUSED COLUMNS ---------------
ALTER TABLE Nashville_Housing
DROP COLUMN owneraddress,taxdistrict, propertyaddress





