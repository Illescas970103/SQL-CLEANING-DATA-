SELECT*
FROM HOUSESBASE.dbo.NASHVILEHOUSING

--FIRST WE NEED TO STANDARIZE OUR DATE INFORMATION
SELECT SaleDate
FROM HOUSESBASE.dbo.NASHVILEHOUSING
--removing the time from this format
SELECT SaleDateconverted,CONVERT(Date,SaleDate)
from HOUSESBASE.dbo.NASHVILEHOUSING

UPDATE NASHVILEHOUSING
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE NASHVILEHOUSING
add SaleDateconverted Date;

UPDATE NASHVILEHOUSING
SET SaleDateconverted=CONVERT(Date,SaleDate)

--property address

SELECT PropertyAddress
FROM HOUSESBASE.dbo.NASHVILEHOUSING
where PropertyAddress is null


--verifying null values in all the data set
SELECT*
FROM HOUSESBASE.dbo.NASHVILEHOUSING
--where PropertyAddress is null
order by ParcelID

--by applying the previous query we discovered that ParcelID AND PropertyAddress will be related with the propaddress
--SO THAT BEEN KNOWN WE GO AHEAD AND POPULATE BOTH COLUMNS
--WE ARE GOING TO SELF JOIN THE TABLE TO ITSELF TO LOOK IF PARCEL ID AND PROPADDRESS ARE THE SAME
Select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
From HOUSESBASE.dbo.NASHVILEHOUSING A
Join HOUSESBASE.dbo.NASHVILEHOUSING B
on  A.ParcelID=B.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]----THIS MEANS THE ID FROM THE TABLE WON'T EVER BE THE SAME
where A.PropertyAddress is null

--LETS UPDATE OUR TABLE
UPDATE A
set PropertyAddress=ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM HOUSESBASE.dbo.NASHVILEHOUSING A
JOIN HOUSESBASE.dbo.NASHVILEHOUSING B
on A.ParcelID=B.ParcelID
AND A.[UniqueID ]<>B.[UniqueID ]
Where A.PropertyAddress is null 

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(address,city,state)
SELECT PropertyAddress
FROM HOUSESBASE.dbo.NASHVILEHOUSING
--order by ParcelID
--we have a coma (,) as a delimiter for separating columns

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))as Address

FROM HOUSESBASE.dbo.NASHVILEHOUSING

ALTER TABLE NASHVILEHOUSING
add PropertySplitAddress Nvarchar(255);

UPDATE NASHVILEHOUSING
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NASHVILEHOUSING
ADD PropertySplitCity Nvarchar(255);

UPDATE NASHVILEHOUSING
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))

SELECT*
FROM HOUSESBASE.dbo.NASHVILEHOUSING


SELECT OwnerAddress
FROM HOUSESBASE.dbo.NASHVILEHOUSING
--LETS SPLIT ALL THIS DATA OUT

--we can use PARSENAME for delimited data

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM HOUSESBASE.dbo.NASHVILEHOUSING

ALTER TABLE NASHVILEHOUSING
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NASHVILEHOUSING
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NASHVILEHOUSING
ADD OwnerSplitCity Nvarchar(255);
UPDATE NASHVILEHOUSING
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NASHVILEHOUSING
ADD OwnerSplitState Nvarchar(255);
UPDATE NASHVILEHOUSING
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--LETS DISCOVER HOW MANY Y,N,YES AND NO VALUES WE HAVE
SELECT*
FROM HOUSESBASE.dbo.NASHVILEHOUSING

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM HOUSESBASE.dbo.NASHVILEHOUSING
group by SoldAsVacant
order by 2

SELECT SoldAsVacant 
,CASE WHEN SoldAsVacant='Y'THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM HOUSESBASE.dbo.NASHVILEHOUSING

UPDATE NASHVILEHOUSING
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
                      WHEN SoldAsVacant='N' THEN 'No'
					  ELSE SoldAsVacant
					  END

--LETS REMOVE DUPLICATES

--WRITING CTE WINDOWS FUNCTIONS TO FIND WHERE ARE DUPLICATE VALUES
WITH ROWNum AS(
SELECT*,

ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			    UniqueID
				)ROW_NUM
FROM HOUSESBASE.dbo.NASHVILEHOUSING
)
---DELETE 
---FROM ROWNum
---WHERE ROW_NUM> 1


SELECT*
FROM ROWNum
WHERE ROW_NUM>1
ORDER BY PropertyAddress

--DELET UNUSED COLUMNS

SELECT*
FROM HOUSESBASE.dbo.NASHVILEHOUSING

ALTER TABLE HOUSESBASE.dbo.NASHVILEHOUSING
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

ALTER TABLE HOUSESBASE.dbo.NASHVILEHOUSING
DROP COLUMN SaleDate