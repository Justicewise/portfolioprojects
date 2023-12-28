select * from [dbo].[housingdata]
-- standarding date format 

select SaleDate, convert(Date,SaleDate)
from [dbo].[housingdata] 

update [dbo].[housingdata]
set SaleDate = convert(Date,SaleDate)

alter table [dbo].[housingdata]
add SaleDateConverted date;

update [dbo].[housingdata]
set SaleDateConverted = convert(Date,SaleDate)

--property address data 
 select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
 from [dbo].[housingdata] a 
 join [dbo].[housingdata] b 
 on a.[ParcelID] = b.[ParcelID]
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null
 --trying to popolate the address a using address b 
 select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 from [dbo].[housingdata] a 
 join [dbo].[housingdata] b 
 on a.[ParcelID] = b.[ParcelID]
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null


 update a 
 set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM  [dbo].[housingdata] a 
 join [dbo].[housingdata] b 
 on a.[ParcelID] = b.[ParcelID]
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null
 --substracting the city from the state using substring and indexing 
 select 
 SUBSTRING(propertyAddress, 1, CHARINDEX(',',propertyAddress) -1) as Address
 ,
 SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress) +1, len(propertyAddress)) as Address
 from [dbo].[housingdata]
 

 alter table [dbo].[housingdata]
add PropertysplitAddress nvarchar(255);

update [dbo].[housingdata]
set PropertysplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',',propertyAddress) -1) 

alter table [dbo].[housingdata]
add PropertySplitCity nvarchar(255);

update [dbo].[housingdata]
set PropertySplitCity =  SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress) +1, len(propertyAddress)) 

select * from [dbo].[housingdata]

select OwnerAddress from [dbo].[housingdata]


--USING PARSENAME TO GET THE SAME RESULT AS SUBSTRING 
select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from [dbo].[housingdata]

alter table [dbo].[housingdata]
add OwnerSplitAddress nvarchar(255);

update [dbo].[housingdata]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

alter table [dbo].[housingdata]
add OwnerSplitCity nvarchar(255);

update [dbo].[housingdata]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

alter table [dbo].[housingdata]
add OwnerSplitState Nvarchar(255);

update [dbo].[housingdata]
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-- change Y and N to Yes and No 'sold as vacant' field 

select distinct(SoldAsVacant), count(SoldAsVacant)
from [dbo].[housingdata]
group by SoldAsVacant
order by 2


select SoldAsvacant ,
case 
when SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' then 'No'
else SoldAsVacant end
from 
[dbo].[housingdata]

update [dbo].[housingdata]
set SoldAsvacant = 
case 
when SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' then 'No'
else SoldAsVacant end

--remove deplicates 

with rownumcte as 
(
select *,
ROW_NUMBER() OVER (
PARTITION BY  ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
order by UniqueID) row_num
from 
[dbo].[housingdata]
) 
delete  from rownumcte 
where row_num >1



--DELETE UNUSED COLMNS

ALTER table [dbo].[housingdata] 
drop

ALTER table [dbo].[housingdata] 
drop column SaleDate