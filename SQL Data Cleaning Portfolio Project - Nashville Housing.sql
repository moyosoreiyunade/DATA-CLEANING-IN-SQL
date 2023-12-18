/*

Cleaning data in sql queries

*/`

SELECT *
FROM PortfolioProject..NashvilleHousing;


---------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format (changing the data type from datetime to just date)

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

SELECT SaleDate
FROM PortfolioProject..NashvilleHousing;


---------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress data

SELECT *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL (A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE B.PropertyAddress IS NULL;

UPDATE B
SET PropertyAddress = ISNULL (A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE B.PropertyAddress IS NULL;


---------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

-- For PropertyAddress

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) AS Address,
		SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +2, LEN (PropertyAddress)) AS Address 
FROM PortfolioProject..NashvilleHousing;


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1);


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +2, LEN (PropertyAddress));


-- For OwnerAddress

SELECT PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
	   PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing;


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1);



---------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing;

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END;



---------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (SELECT *,
						  ROW_NUMBER() OVER (PARTITION BY ParcelID,
														  PropertyAddress,
														  SaleDate,
														  SalePrice,
														  LegalReference
											 ORDER BY UniqueID) AS row_num
				   FROM PortfolioProject..NashvilleHousing)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;



---------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict