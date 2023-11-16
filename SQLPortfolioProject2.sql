SELECT *
FROM PortfolioProject..NashvilleHousing


--Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD
SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND 
A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND 
A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--Breaking out address into individual columns (address,city,state)
SELECT SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashVilleHousing
Add PropertySplitAddress nvarchar(255)

UPDATE NashVilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashVilleHousing
Add PropertySplitCity nvarchar(255)

UPDATE NashVilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL


ALTER TABLE NashVilleHousing
Add OwnerSplitAddress nvarchar(255)

UPDATE NashVilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashVilleHousing
Add OwnerSplitCity nvarchar(255)

UPDATE NashVilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashVilleHousing
Add OwnerSplitState nvarchar(255)

UPDATE NashVilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant)
FROM NashvilleHousing

SELECT SoldAsVacant
,CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION  BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) row_num

From NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- Delete Unused Columns
SELECT *
FROM NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
DROP COLUMN SaleDate
