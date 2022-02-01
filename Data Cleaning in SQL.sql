

--Cleaning data in sql 


select *
from PortfolioProject..NashvilleHousing


--Standardize date format


select saledateconverted, convert(date, SaleDate)
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add saledateconverted date;


update NashvilleHousing
set saledateconverted = convert(date, SaleDate)



--Populate property address data


select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out property address into individual columns (Address, city, state)



select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select 
--substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))as Address, CHARINDEX(',', PropertyAddress)
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))as Address
from PortfolioProject..NashvilleHousing



alter table NashvilleHousing
add propertysplitaddress nvarchar(255);


update NashvilleHousing
set propertysplitaddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


alter table NashvilleHousing
add propertysplitcity1 nvarchar(255);


update NashvilleHousing
set propertysplitcity1 = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))



select *
from NashvilleHousing



--Breaking out property address into individual columns (Address, city, state)


select OwnerAddress
from NashvilleHousing


select
PARSENAME(replace(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)
from NashvilleHousing



alter table NashvilleHousing
add ownersplitaddress nvarchar(255);


update NashvilleHousing
set ownersplitaddress = PARSENAME(replace(OwnerAddress, ',', '.'),3)


alter table NashvilleHousing
add ownersplitcity nvarchar(255);


update NashvilleHousing
set ownersplitcity = PARSENAME(replace(OwnerAddress, ',', '.'),2)



alter table NashvilleHousing
add ownersplitstate nvarchar(255);


update NashvilleHousing
set ownersplitstate = PARSENAME(replace(OwnerAddress, ',', '.'),1)



select *
from NashvilleHousing



--Change Y and N to YES and NO in 'Sold as vacant' field



select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2




select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end



--Remove duplicates


with RowNumCTE as (
select *,
ROW_NUMBER() over(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from NashvilleHousing
)
--delete
--from RowNumCTE
--where row_num > 1
--order by PropertyAddress

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress





--Delete unused columns



select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress