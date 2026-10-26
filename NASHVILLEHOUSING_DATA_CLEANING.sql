

SELECT *
FROM [Portfolio Project]..NashvilleHousing



-----------------------------------------------------------
--STANDARDIZE DATE FORMAT


SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD ConvertedSaleDate Date;

UPDATE [Portfolio Project]..NashvilleHousing
SET ConvertedSaleDate = CONVERT(Date, SaleDate)

SELECT *
FROM [Portfolio Project]..NashvilleHousing

-----------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA

SELECT N1.ParcelID, N1.PropertyAddress, N2.ParcelID, N2.PropertyAddress, ISNULL( N1.PropertyAddress, N2.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing AS N1
JOIN [Portfolio Project]..NashvilleHousing AS N2
	ON N1.ParcelID = N2.ParcelID
	AND N1.[UniqueID ] <> N2.[UniqueID ]
WHERE N1.PropertyAddress is null

UPDATE N1
SET PropertyAddress = ISNULL( N1.PropertyAddress, N2.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing AS N1
JOIN [Portfolio Project]..NashvilleHousing AS N2
	ON N1.ParcelID = N2.ParcelID
	AND N1.[UniqueID ] <> N2.[UniqueID ]
WHERE N1.PropertyAddress is null

SELECT *
FROM [Portfolio Project]..NashvilleHousing

-----------------------------------------------------------
--BREAKING ADDRESS TO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress) -1) AS PropertyAddress ,
SUBSTRING(PropertyAddress, CHARINDEX( ',' , PropertyAddress) +1, LEN( PropertyAddress)) AS PropertyAddressCity
FROM [Portfolio Project]..NashvilleHousing
 
ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress) -1)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD PropertyAddressCity nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX( ',' , PropertyAddress) +1, LEN( PropertyAddress))

SELECT *
FROM [Portfolio Project]..NashvilleHousing




SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT
	PARSENAME(REPLACE( OwnerAddress, ',' , '.') , 3),
	PARSENAME(REPLACE( OwnerAddress, ',' , '.') , 2),
	PARSENAME(REPLACE( OwnerAddress, ',' , '.') , 1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE( OwnerAddress, ',' , '.') , 1)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerAddressCity nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE( OwnerAddress, ',' , '.') , 2)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerAddressState nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE( OwnerAddress, ',' , '.') , 3)


SELECT *
FROM [Portfolio Project]..NashvilleHousing

-----------------------------------------------------------
-- DELETE UNSED COLUMNS

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN PropertyxAddress


-----------------------------------------------------------
-- REMOVE DUPLICATES

WITH CTE_X AS (
SELECT *,
	ROW_NUMBER () OVER (
				PARTITION BY  ParcelID,
							  PropertyAddress,
						   	  OwnerAddress,
							  LegalReference
						
				ORDER BY ParcelID) AS ROW_NUM
FROM [Portfolio Project]..NashvilleHousing
)
DELETE
FROM CTE_X
WHERE ROW_NUM > 1

-----------------------------------------------------------
-- CHANGE 'Y' AND 'N' TO 'YES' AND 'NO'

SELECT DISTINCT( SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
	END
FROM [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					     WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
					END

SELECT *
FROM [Portfolio Project]..NashvilleHousing