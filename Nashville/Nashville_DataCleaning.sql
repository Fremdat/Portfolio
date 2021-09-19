/*

Cleaning Data in SQL

*/

Select *
From PortfolioProject..NashvilleHousing
------------------------------------------------------------

-- Format Date Format

Select SaleDateConverted--, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

ALTER Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


------------------------------------------------------------

----- Populate Property Address Data

-- There are NULL values

-- ParcelID might be twice in Database (i.e. same property appears twice)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
Where PropertyAddress is null

-- Use the Property Address from the observation with the same ParcelID:

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.propertyAddress) --PropertyAddress
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET propertyaddress = ISNULL(a.propertyAddress, b.propertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null







------------------------------------------------------------

----- Breaking out Address into Individual Columns(Address, City, State

--- Property Address:

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing



ALTER Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing



--- Owner Address:

Select OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',','.'),2) as City
, PARSENAME(REPLACE(OwnerAddress, ',','.'),1) as State
FROM PortfolioProject..NashvilleHousing


ALTER Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


ALTER Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM PortfolioProject..NashvilleHousing


------------------------------------------------------------

----- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
, Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
FROM PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


------------------------------------------------------------

----- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY  ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
						UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1



------------------------------------------------------------

----- Remove Unused Columns


Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate