--PROJECT2: Data Cleaning in SQL

SELECT * FROM NashvilleHousing

--Standardize date format
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateFormat Date;

UPDATE NashvilleHousing
SET SaleDateFormat = CONVERT(DATE, SaleDate)

--Populate property address data
SELECT * FROM NashvilleHousing ORDER BY ParcelID

SELECT * 
FROM NashvilleHousing a
JOIN NashvilleHousing b ON
a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b ON
a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b ON
a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual columns [Address, city, State]

SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) -1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing ADD SplittedAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET SplittedAddress = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing ADD SplittedCity Nvarchar(255);

UPDATE NashvilleHousing 
SET SplittedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) -1, LEN(PropertyAddress))

SELECT * FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

--Change Y TO Yes and N To No in 'SoldAsVacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	                    WHEN SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END

--Removing duplicates
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (
			PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
			ORDER BY UniqueID) row_num
FROM NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1 


--SELECT * FROM RowNumCTE
--WHERE row_num > 1 
--ORDER BY PropertyAddress


--Deleting the unused data

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate