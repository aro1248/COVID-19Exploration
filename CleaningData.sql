/* Cleaning Data in SQL */

SELECT *
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
-- Did not update Properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Updated Properly
----------------------------------------------------------------------------------------------------------------------
/* Property Address */
-- Using ParcelID to Populate Null Property Address

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null 
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------
/* Breaking out Property Address into Individual Columns (Address, City)*/

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING ( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING ( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress))

----------------------------------------------------------------------------------------------------------------------

/* Breaking out Owner Address into Individual Columns (Address, City,State) */

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3 ),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2 ),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1 )
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3 )

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2 )

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1 )

----------------------------------------------------------------------------------------------------------------------

/* Changing Y and N to Yes and No in Sold as Vacant Field */

SELECT Distinct(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

----------------------------------------------------------------------------------------------------------------------
/* Remove Duplicates */

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

----------------------------------------------------------------------------------------------------------------------
-- Deleting Unused Columns 

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * 
FROM PortfolioProject..NashvilleHousing